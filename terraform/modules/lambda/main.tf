data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Create a policy document for logging permissions
data "aws_iam_policy_document" "lambda_logging_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]  # You can restrict this to specific log groups if needed
  }
}

# Attach the logging policy to the IAM role
resource "aws_iam_policy" "lambda_logging" {
  name        = "LambdaLoggingPolicy"
  description = "Policy to allow Lambda functions to write logs to CloudWatch"
  policy      = data.aws_iam_policy_document.lambda_logging_policy.json
}

resource "aws_iam_policy_attachment" "attach_logging_policy" {
  name       = "AttachLambdaLoggingPolicy"
  roles      = [aws_iam_role.iam_for_lambda.name]
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false  # Ensure no uppercase letters
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "bucket-transaction-history-${random_string.random.result}"
  acl    = "private"
}

# Add permission for S3 to invoke the Lambda function
resource "aws_lambda_permission" "allow_s3_invoke" {
  function_name = aws_lambda_function.transaction_processor.function_name
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.lambda_bucket.arn
}

resource "aws_lambda_function" "transaction_processor" {
  function_name = "TransactionProcessor"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  source_code_hash = filebase64sha256("${path.module}/index.zip")
  role          = aws_iam_role.iam_for_lambda.arn
  # Specify the source code location directly from a local file
  filename      = "${path.module}/index.zip"

  # Define timeout and memory settings
  timeout       = 30
  memory_size   = 128
}

# Define a trigger for the Lambda function from the newly created S3 bucket
resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = aws_s3_bucket.lambda_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.transaction_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".json"
  }

  depends_on = [
    aws_s3_bucket.lambda_bucket,
    aws_lambda_permission.allow_s3_invoke
  ]
}

# Create a policy document for S3 access permissions
data "aws_iam_policy_document" "lambda_s3_access" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = ["*"]
  }
}

# Create an IAM policy for S3 access permissions
resource "aws_iam_policy" "lambda_s3_access_policy" {
  name        = "LambdaS3AccessPolicy"
  description = "Policy to allow Lambda functions to access specific S3 bucket objects"
  policy      = data.aws_iam_policy_document.lambda_s3_access.json
}

# Attach the S3 access policy to the IAM role
resource "aws_iam_policy_attachment" "attach_s3_access_policy" {
  name       = "AttachS3AccessPolicyToLambdaRole"
  roles      = [aws_iam_role.iam_for_lambda.name]
  policy_arn = aws_iam_policy.lambda_s3_access_policy.arn
}
