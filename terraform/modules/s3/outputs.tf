output "bucket_name" {
  value = aws_s3_bucket.user_documents.bucket
}

output "url" {
  value = aws_s3_bucket.user_documents.website_endpoint
}

