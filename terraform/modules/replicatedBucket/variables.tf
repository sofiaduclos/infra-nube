variable "source_bucket_name" {
  description = "Nombre del bucket de origen para replicación"
  type        = string
}

variable "destination_bucket_name" {
  description = "Nombre del bucket de destino para replicación"
  type        = string
}

variable "source_region" {
  description = "Región del bucket de origen"
  type        = string
}

variable "destination_region" {
  description = "Región del bucket de destino"
  type        = string
}

variable "iam_role_name" {
  description = "Nombre del rol IAM para replicación"
  type        = string
  default     = "tf-s3-replication-role"
}
