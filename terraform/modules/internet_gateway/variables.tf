variable "vpc_id" {
  type        = string
  description = "The VPC ID to attach the Internet Gateway to"
}

variable "route_table_id" {
  type        = string
  description = "The route table ID to update with the Internet Gateway route"
}

