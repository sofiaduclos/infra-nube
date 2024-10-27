variable "name" {
  description = "The name of the load balancer"
  type        = string
}

variable "subnets" {
  description = "The subnets to attach to the load balancer"
  type        = list(string)
}

variable "security_groups" {
  description = "The security groups to associate with the load balancer"
  type        = list(string)
}

variable "target_instance_arns" {
  description = "The ARNs of the EC2 instances to register with the target group"
  type        = list(string)
}

variable "vpc_id" {
  description = "The VPC ID where the load balancer and instances are located"
  type        = string
}
