variable "ami_id" {
  type = string
  description = "La AMI para la instancia EC2"
}

variable "instance_type" {
  type = string
  description = "El tipo de instancia EC2"
  default = "t3.micro"
}

variable "key_name" {
  type = string
  description = "Llave SSH para acceder a la instancia"
}

variable "subnet_id" {
  type = string
  description = "El ID de la subred"
}
