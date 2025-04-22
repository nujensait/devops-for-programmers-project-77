terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket     = "terraform-state-prj3"  # Имя бакета в Yandex Object Storage
    key        = "terraform/state.tfstate"
    region     = "ru-central1"
    
    # Учетные данные нужно указать здесь или передать через -backend-config
    access_key = "YCAJEym00ii1IK_lhoE3rvuLg"  # Замените на ваш ключ доступа
    secret_key = "YCNvvSt6Tq0YJvsR18FcRlQ5WkhrSOicBj5i9ZyA"  # Замените на ваш секретный ключ
    
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true  # Добавлено для Yandex Cloud
    skip_s3_checksum            = true  # Добавлено для совместимости
  }
}
