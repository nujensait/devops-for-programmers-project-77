terraform {
  # Временно используем локальный бэкенд вместо S3 из-за проблем с подключением
  backend "local" {
    path = "terraform.tfstate"
  }
  
  # Закомментированная конфигурация S3 бэкенда для будущего использования
  /*
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket     = "terraform-state-prj3"  # Имя бакета в Yandex Object Storage
    key        = "terraform/state.tfstate"
    region     = "ru-central1"
    
    # Ключи доступа будут переданы через -backend-config
    # access_key = "..."
    # secret_key = "..."
    
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true  # Добавлено для Yandex Cloud
    skip_s3_checksum            = true  # Добавлено для совместимости
  }
  */
}
