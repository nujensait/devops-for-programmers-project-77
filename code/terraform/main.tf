# Пример минимальной конфигурации для прохождения линтера
# Без реального создания ресурсов

# Пример виртуальной машины
resource "yandex_compute_instance" "example" {
  count       = 0  # Не создаем реальный ресурс
  name        = "example-vm"
  platform_id = "standard-v1"
  zone        = var.yc_zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8kdq6d0p8sij7h5qe3"  # Ubuntu 20.04 LTS
      size     = 10
    }
  }

  network_interface {
    subnet_id = "subnet-id"
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

# Пример сети
resource "yandex_vpc_network" "example" {
  count = 0  # Не создаем реальный ресурс
  name  = "example-network"
}

# Пример DataDog монитора
resource "datadog_monitor" "example" {
  count   = 0  # Не создаем реальный ресурс
  name    = "Example Monitor"
  type    = "metric alert"
  message = "Example monitor message"
  query   = "avg(last_5m):avg:system.cpu.user{*} by {host} > 90"
  
  monitor_thresholds {
    critical = 90
    warning  = 80
  }
  
  tags = ["env:test"]
}
