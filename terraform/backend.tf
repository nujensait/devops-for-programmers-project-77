terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "your-bucket-name"  # Имя бакета в Yandex Object Storage
    key        = "terraform/state.tfstate"
    region     = "ru-central1"
    access_key = var.s3_access_key
    secret_key = var.s3_secret_key
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
