output "source_bucket_name" {
  value = aws_s3_bucket.source.bucket
}

output "destination_bucket_name" {
  value = aws_s3_bucket.destination.bucket
}

output "replication_role_arn" {
  value = aws_iam_role.replication_role.arn
}
