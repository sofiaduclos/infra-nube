resource "aws_sns_topic" "notification_topic" {
  name = "notification_topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.notification_topic.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_lambda_function" "sqs_to_sns" {
  function_name = "sqs_to_sns"
  handler       = "index.handler"  // Adjust based on your Lambda code
  runtime       = "nodejs20.x"      // Adjust based on your runtime
  role          = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256("${path.module}/index.zip") // Path to your Lambda deployment package
  filename      = "${path.module}/index.zip"

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.notification_topic.arn
    }
  }
}


resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_sqs_sns" {
  name       = "lambda_sqs_sns_policy"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_iam_policy_attachment" "lambda_sns_publish" {
  name       = "lambda_sns_publish_policy"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.sqs_to_sns.arn
  enabled          = true
}
