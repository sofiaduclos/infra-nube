const { SNSClient, PublishCommand } = require('@aws-sdk/client-sns');

const snsClient = new SNSClient({});

exports.handler = async (event) => {
    for (const record of event.Records) {
        const message = record.body;

        const params = {
            Message: message,
            TopicArn: process.env.SNS_TOPIC_ARN, // Get the SNS topic ARN from environment variables
        };

        try {
            const command = new PublishCommand(params);
            await snsClient.send(command);
            console.log(`Message sent to SNS: ${message}`);
        } catch (error) {
            console.error(`Error sending message to SNS: ${error}`);
            throw new Error(`Error sending message to SNS: ${error}`);
        }
    }
};
