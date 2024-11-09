const { S3Client, GetObjectCommand } = require('@aws-sdk/client-s3');

// Initialize the S3 client with your desired region
const s3Client = new S3Client({ region: 'us-east-1' });

exports.handler = async (event) => {
    const validCurrencies = ["USD", "CAD", "EUR", "GBP", "UYU", "ARS", "BRL", "CLP", "COP", "PEN", "PYG", "MXN"];
    
    for (const record of event.Records) {
        const bucket = record.s3.bucket.name;
        const key = record.s3.object.key;

        try {
            const command = new GetObjectCommand({ Bucket: bucket, Key: key });
            const data = await s3Client.send(command);
            
            // Convert the stream to a string
            const bodyContents = await streamToString(data.Body);
            const transaction = JSON.parse(bodyContents); // Changed to a single object

            // Validate the transaction
            if (!validateTransaction(transaction, validCurrencies)) {
                console.error("Invalid transaction:", transaction);
                return; // Or handle the error as needed
            }

            // Process the transaction (add your business logic here)
            console.log("Processing transaction:", transaction);
        } catch (error) {
            console.error("Error processing file:", error);
        }
    }
};

// Helper function to convert stream to string
const streamToString = (stream) =>
    new Promise((resolve, reject) => {
        const chunks = [];
        stream.on("data", (chunk) => chunks.push(chunk));
        stream.on("error", reject);
        stream.on("end", () => resolve(Buffer.concat(chunks).toString("utf-8")));
    });

function validateTransaction(transaction, validCurrencies) {
    // Validate required fields
    if (typeof transaction.transaction_id !== 'string' || 
        typeof transaction.sender_bank_code !== 'string' || 
        typeof transaction.sender_account_number !== 'string' || 
        typeof transaction.receiver_account_number !== 'string' || 
        typeof transaction.amount !== 'number' || 
        typeof transaction.currency !== 'string' || 
        typeof transaction.transaction_date !== 'string') {
        return false;
    }

    // Validate currency format
    if (!validCurrencies.includes(transaction.currency)) {
        return false;
    }

    // Validate date format (ISO)
    if (isNaN(Date.parse(transaction.transaction_date))) {
        return false;
    }

    // Validate that description, if exists, is a string
    if (transaction.description && typeof transaction.description !== 'string') {
        return false;
    }

    return true;
}