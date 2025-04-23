variable "yc_token" {
  description = "Yandex Cloud OAuth token"
  type        = string
  sensitive   = true
}

variable "yc_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "yc_folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "yc_zone" {
  description = "Yandex Cloud default zone"
  type        = string
  default     = "ru-central1-a"
}

# Переменные S3 закомментированы, так как мы используем локальный бэкенд
# Раскомментируйте их, если вернётесь к использованию S3 бэкенда
/*
variable "s3_access_key" {
  description = "Yandex Object Storage access key"
  type        = string
  sensitive   = true
}

variable "s3_secret_key" {
  description = "Yandex Object Storage secret key"
  type        = string
  sensitive   = true
}
*/

# DataDog variables
variable "datadog_api_key" {
  description = "DataDog API key"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "DataDog Application key"
  type        = string
  sensitive   = true
}

variable "datadog_site" {
  description = "DataDog site (datadoghq.com, datadoghq.eu, etc.)"
  type        = string
  default     = "datadoghq.com"
}

# SSH public key
variable "ssh_public_key" {
  description = "SSH public key for VM instances"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 example@example.com"
}
