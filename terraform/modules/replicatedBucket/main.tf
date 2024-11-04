# Proveedor para la región de origen
provider "aws" {
  alias  = "source"
  region = var.source_region
}

# Proveedor para la región de destino
provider "aws" {
  alias  = "destination"
  region = var.destination_region
}

# Documento de política para el rol de replicación
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# Crear el rol IAM para la replicación
resource "aws_iam_role" "replication_role" {
  name               = var.iam_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Política para el rol IAM con permisos necesarios para replicación
data "aws_iam_policy_document" "replication_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.source.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging"
    ]
    resources = ["${aws_s3_bucket.source.arn}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags"
    ]
    resources = ["${aws_s3_bucket.destination.arn}/*"]
  }
}

# Asociar la política al rol de replicación
resource "aws_iam_policy" "replication_policy" {
  name   = "${var.iam_role_name}-policy"
  policy = data.aws_iam_policy_document.replication_policy.json
}

resource "aws_iam_role_policy_attachment" "replication_attachment" {
  role       = aws_iam_role.replication_role.name
  policy_arn = aws_iam_policy.replication_policy.arn
}

# Crear el bucket de origen con versioning habilitado
resource "aws_s3_bucket" "source" {
  provider = aws.source
  bucket   = var.source_bucket_name

  versioning {
    enabled = true
  }
}

# Crear el bucket de destino con versioning habilitado
resource "aws_s3_bucket" "destination" {
  provider = aws.destination
  bucket   = var.destination_bucket_name

  versioning {
    enabled = true
  }
}

# Configuración de replicación en el bucket de origen
resource "aws_s3_bucket_replication_configuration" "replication" {
  provider = aws.source

  role   = aws_iam_role.replication_role.arn
  bucket = aws_s3_bucket.source.id

  rule {
    id     = "replication-rule"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.destination.arn
      storage_class = "STANDARD"
    }
  }
}
