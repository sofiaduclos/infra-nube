resource "aws_lambda_function" "transaction_processor" {
  function_name = "TransactionProcessor"
  handler       = "index.handler" # Update this according to your file and function name
  runtime       = "nodejs14.x"     # Choose your preferred runtime
  role          = aws_iam_role.lambda_exec.arn

  # Specify the source code location
  s3_bucket     = aws_s3_bucket.lambda_bucket.bucket
  s3_key        = "path/to/your/code.zip" # Adjust this to the actual path

  environment {
    # You can define environment variables here
    ENV_VAR_NAME = "value"
  }

  # Define timeout and memory settings
  timeout       = 30
  memory_size   = 128
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "your-unique-bucket-name" # Ensure this bucket name is unique across AWS
}

# You can define a trigger for the Lambda function, e.g., from an S3 bucket
resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = aws_s3_bucket.lambda_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.transaction_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_function.transaction_processor]
}
