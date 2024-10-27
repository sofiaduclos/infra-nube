resource "aws_s3_bucket" "user_documents" {
  bucket = var.bucket_name

  versioning {
    enabled = true  # Maintains versions of the files
  }

}

// Configure the S3 bucket for website hosting
resource "aws_s3_bucket_website_configuration" "website" {
  count  = var.is_static_site ? 1 : 0  // Create configuration only if is_static_site is true
  bucket = aws_s3_bucket.user_documents.id

  index_document {
    suffix = var.index_document  // Use the variable for index document
  }

  error_document {
    key = var.error_document  // Use the variable for error document
  }

}


resource "aws_s3_bucket_public_access_block" "user_documents_public_access" {
  bucket = aws_s3_bucket.user_documents.id

  # Allow policies with public access (Adjust based on your requirements)
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

// Define the bucket policy only if is_static_site is true
resource "aws_s3_bucket_policy" "bucket_policy" {
  count  = var.is_static_site ? 1 : 0  // Create policy only if is_static_site is true
  bucket = aws_s3_bucket.user_documents.id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": "${aws_s3_bucket.user_documents.arn}/*"
      }
    ]
  }
  EOF
}

// Upload the static page to the S3 bucket
resource "aws_s3_bucket_object" "static_page" {
  count  = var.is_static_site ? 1 : 0 
  bucket = aws_s3_bucket.user_documents.id
  key    = var.index_document
  source = var.static_page_path
  content_type = "text/html"
}
