terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket     = "your-bucket-name"  # Имя бакета в Yandex Object Storage
    key        = "terraform/state.tfstate"
    region     = "ru-central1"
    
    # Учетные данные нужно указать здесь или передать через -backend-config
    access_key = "your-access-key"  # Замените на ваш ключ доступа
    secret_key = "your-secret-key"  # Замените на ваш секретный ключ
    
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true  # Добавлено для Yandex Cloud
    skip_s3_checksum            = true  # Добавлено для совместимости
  }
}
