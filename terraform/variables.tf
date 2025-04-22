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
