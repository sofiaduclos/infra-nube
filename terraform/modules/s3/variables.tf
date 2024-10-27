variable "bucket_name" {
  type        = string
  description = "El nombre del bucket para almacenar documentos"
}

variable "index_document" {
  type        = string
  description = "El documento de índice para el sitio estático"
  default     = ""  # Default to empty for general-purpose buckets
}

variable "error_document" {
  type        = string
  description = "El documento de error para el sitio estático"
  default     = ""  # Default to empty for general-purpose buckets
}


variable "static_page_path" {
  description = "The path to the static page for the website"
  type        = string
}

variable "is_static_site" {
  description = "Whether this is a static site"
  type        = bool
  default     = false
}
