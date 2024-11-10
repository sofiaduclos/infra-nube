variable "ami_id" {
  type        = string
  description = "The AMI ID for the EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "The instance type for the EC2 instance"
  default     = "t3.micro"  # Default instance type
}


variable "subnet_id" {
  type        = string
  description = "The subnet ID where the instance will be launched"
}

variable "security_group_id" {
  type        = string
  description = "The security group ID to associate with the EC2 instance"
}

variable "code_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to store the code"
}

