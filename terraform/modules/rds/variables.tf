variable "db_name" {
  type = string
  description = "Nombre de la base de datos PostgreSQL"
}

variable "db_username" {
  type = string
  description = "Usuario administrador para la base de datos"
}

variable "db_password" {
  type = string
  description = "Contraseña para el usuario administrador"
}

variable "subnet_group_name" {
  type = string
  description = "Nombre del grupo de subredes para la base de datos"
}

variable "security_group_id" {
  type = string
  description = "ID del grupo de seguridad para la base de datos"
}

