resource "aws_iam_role" "lambda_exec" {
  name = "LambdaExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Effect = "Allow"
      Sid    = ""
    }]
  })
}

resource "aws_iam_policy_attachment" "lambda_policy_attach" {
  name       = "LambdaPolicyAttachment"
  roles      = [aws_iam_role.lambda_exec.name]
  policies   = ["service-role/AWSLambdaBasicExecutionRole"] # Gives CloudWatch Logs permissions
}
