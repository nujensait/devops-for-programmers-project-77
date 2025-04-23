terraform {
  # Временно используем локальный бэкенд
  # вместо S3 из-за проблем с подключением
  backend "local" {
    path = "terraform.tfstate"
  }
  
  # Конфигурация для S3 бэкенда (закомментирована)
  /*
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket     = "terraform-state-prj3"
    key        = "terraform/state.tfstate"
    region     = "ru-central1"
    
    # Учетные данные должны быть указаны через -backend-config
    # или в файле backend.tfvars
    
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
  */
}
