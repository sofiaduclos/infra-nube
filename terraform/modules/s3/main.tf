resource "aws_s3_bucket" "user_documents" {
  bucket = var.bucket_name

  versioning {
    enabled = true  # Mantiene las versiones de los archivos
  }

  lifecycle {
    prevent_destroy = true  # Evitar que el bucket sea eliminado accidentalmente
  }

  # Configura replicación si es requerida (multi-region)
}

resource "aws_s3_bucket_policy" "bucket_policy" {
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
