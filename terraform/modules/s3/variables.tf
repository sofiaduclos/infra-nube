variable "bucket_name" {
  type        = string
  description = "El nombre del bucket para almacenar documentos"
}

variable "index_document" {
  type        = string
  description = "El documento de índice para el sitio estático"
  default     = ""
}

variable "error_document" {
  type        = string
  description = "El documento de error para el sitio estático"
  default     = ""
}


variable "static_page_path" {
  description = "The path to the static page for the website"
  type        = string
  default     = ""
}

variable "is_static_site" {
  description = "Whether this is a static site"
  type        = bool
  default     = false
}

variable "is_pwa" {
  description = "Flag to indicate if the site is a PWA"
  type        = bool
  default     = false
}

variable "pwa_file_path_folder" {
  description = "The path to the PWA files"
  type        = string
  default     = ""
}
