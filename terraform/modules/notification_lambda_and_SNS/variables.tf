variable "notification_email" {
  description = "Email address for SNS subscription"
  type        = string
}

variable "sqs_queue_arn" {
  description = "ARN of the SQS queue"
  type        = string
}
