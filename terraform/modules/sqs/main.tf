resource "aws_sqs_queue" "terraform_queue" {
  name                      = "notification-queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  tags = {
    Environment = "production"
  }
}

resource "aws_ssm_parameter" "sqs_queue_url" {
  name  = "/myapp/sqs_queue_url"
  type  = "String"
  value = aws_sqs_queue.terraform_queue.id
}