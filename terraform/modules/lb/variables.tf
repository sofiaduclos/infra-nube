variable "name" {
  description = "The name of the load balancer"
  type        = string
}

variable "security_groups" {
  description = "The security groups to associate with the load balancer"
  type        = list(string)
}

variable "subnet" {
  description = "The subnet to associate with the load balancer"
  type        = list(string)
}

variable "target_group_arn" {
  description = "The target group arn to associate with the load balancer"
  type        = string
}
