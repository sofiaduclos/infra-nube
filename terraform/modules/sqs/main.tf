resource "aws_sqs_queue" "terraform_queue" {
  name                        = "notification-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
}

resource "aws_ssm_parameter" "sqs_queue_url" {
  name  = "/myapp/sqs_queue_url"
  type  = "String"
  value = aws_sqs_queue.terraform_queue.id
}