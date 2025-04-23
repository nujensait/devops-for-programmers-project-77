# Основная конфигурация инфраструктуры

# Создание сети
resource "yandex_vpc_network" "app_network" {
  name = "app-network"
}

# Создание подсети
resource "yandex_vpc_subnet" "app_subnet" {
  name           = "app-subnet"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.app_network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Создание группы безопасности для серверов
resource "yandex_vpc_security_group" "app_sg" {
  name        = "app-sg"
  network_id  = yandex_vpc_network.app_network.id

  # Разрешаем входящий трафик на порт 80 (HTTP)
  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Разрешаем входящий трафик на порт 443 (HTTPS)
  ingress {
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Разрешаем входящий трафик на порт 22 (SSH)
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Разрешаем входящий трафик для проверок работоспособности от Yandex Cloud
  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = [
      "198.18.235.0/24",   # Диапазон IP для проверок работоспособности Yandex Cloud
      "198.18.248.0/24",   # Дополнительный диапазон для проверок работоспособности
      "172.16.0.0/12",     # Внутренние адреса Yandex Cloud
      "10.0.0.0/8",        # Внутренние адреса Yandex Cloud
      "192.168.0.0/16"     # Внутренние адреса Yandex Cloud
    ]
    description = "Healthchecks from Yandex Cloud"
  }

  # Разрешаем весь входящий трафик из подсети
  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = [yandex_vpc_subnet.app_subnet.v4_cidr_blocks[0]]
    description    = "All traffic from subnet"
  }

  # Разрешаем исходящий трафик
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Создание группы безопасности для балансировщика нагрузки
resource "yandex_vpc_security_group" "lb_sg" {
  name        = "lb-sg"
  network_id  = yandex_vpc_network.app_network.id

  # Разрешаем входящий трафик на порт 80 (HTTP)
  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "HTTP traffic from internet"
  }

  # Разрешаем входящий трафик на порт 443 (HTTPS)
  ingress {
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "HTTPS traffic from internet"
  }

  # Разрешаем весь входящий трафик для проверок работоспособности
  ingress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "All healthcheck traffic"
  }

  # Разрешаем исходящий трафик к серверам
  egress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = [yandex_vpc_subnet.app_subnet.v4_cidr_blocks[0]]
    description    = "HTTP traffic to backend servers"
  }

  # Разрешаем весь исходящий трафик
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "All outgoing traffic"
  }
}

# Создание первой виртуальной машины
resource "yandex_compute_instance" "web_server_1" {
  name        = "web-server-1"
  platform_id = "standard-v1"
  zone        = var.yc_zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8kdq6d0p8sij7h5qe3" # Ubuntu 20.04 LTS
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.app_subnet.id
    security_group_ids = [yandex_vpc_security_group.app_sg.id]
    nat                = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
    user-data = <<-EOF
      #!/bin/bash
      apt-get update
      apt-get install -y nginx
      
      # Создаем HTML-файл с приветствием на разных языках
      cat > /var/www/html/index.html << 'EOL'
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>Hello World</title>
        <style>
          body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            background-color: #f5f5f5;
          }
          .container {
            text-align: center;
            padding: 40px;
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
          }
          h1 {
            color: #333;
            font-size: 3em;
            margin-bottom: 10px;
          }
          p {
            color: #666;
            font-size: 1.2em;
          }
          .server-info {
            margin-top: 20px;
            padding: 10px;
            background-color: #f0f0f0;
            border-radius: 5px;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1 id="greeting">Hello World!</h1>
          <p id="welcome">Welcome to our website!</p>
          <div class="server-info">
            <p>Server: Web Server 1</p>
            <p>Hostname: $(hostname)</p>
            <p>IP: $(hostname -I | awk '{print $1}')</p>
          </div>
        </div>
        
        <script>
          // Определение языка браузера
          const userLang = navigator.language || navigator.userLanguage;
          const greetingElement = document.getElementById('greeting');
          const welcomeElement = document.getElementById('welcome');
          
          // Приветствия на разных языках
          const greetings = {
            'ru': 'Привет, мир!',
            'en': 'Hello World!',
            'es': '¡Hola Mundo!',
            'fr': 'Bonjour le monde!',
            'de': 'Hallo Welt!',
            'it': 'Ciao Mondo!',
            'zh': '你好，世界！',
            'ja': 'こんにちは世界！'
          };
          
          const welcomeMessages = {
            'ru': 'Добро пожаловать на наш сайт!',
            'en': 'Welcome to our website!',
            'es': '¡Bienvenido a nuestro sitio web!',
            'fr': 'Bienvenue sur notre site!',
            'de': 'Willkommen auf unserer Website!',
            'it': 'Benvenuto nel nostro sito web!',
            'zh': '欢迎访问我们的网站！',
            'ja': '私たちのウェブサイトへようこそ！'
          };
          
          // Получаем код языка (первые 2 символа)
          const langCode = userLang.substring(0, 2);
          
          // Устанавливаем приветствие на языке пользователя или на английском по умолчанию
          greetingElement.textContent = greetings[langCode] || greetings['en'];
          welcomeElement.textContent = welcomeMessages[langCode] || welcomeMessages['en'];
        </script>
      </body>
      </html>
      EOL
      
      # Перезапускаем Nginx
      systemctl restart nginx
    EOF
  }
}

# Создание второй виртуальной машины
resource "yandex_compute_instance" "web_server_2" {
  name        = "web-server-2"
  platform_id = "standard-v1"
  zone        = var.yc_zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8kdq6d0p8sij7h5qe3" # Ubuntu 20.04 LTS
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.app_subnet.id
    security_group_ids = [yandex_vpc_security_group.app_sg.id]
    nat                = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
    user-data = <<-EOF
      #!/bin/bash
      apt-get update
      apt-get install -y nginx
      
      # Создаем HTML-файл с приветствием на разных языках
      cat > /var/www/html/index.html << 'EOL'
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>Hello World</title>
        <style>
          body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            background-color: #f5f5f5;
          }
          .container {
            text-align: center;
            padding: 40px;
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
          }
          h1 {
            color: #333;
            font-size: 3em;
            margin-bottom: 10px;
          }
          p {
            color: #666;
            font-size: 1.2em;
          }
          .server-info {
            margin-top: 20px;
            padding: 10px;
            background-color: #f0f0f0;
            border-radius: 5px;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1 id="greeting">Hello World!</h1>
          <p id="welcome">Welcome to our website!</p>
          <div class="server-info">
            <p>Server: Web Server 2</p>
            <p>Hostname: $(hostname)</p>
            <p>IP: $(hostname -I | awk '{print $1}')</p>
          </div>
        </div>
        
        <script>
          // Определение языка браузера
          const userLang = navigator.language || navigator.userLanguage;
          const greetingElement = document.getElementById('greeting');
          const welcomeElement = document.getElementById('welcome');
          
          // Приветствия на разных языках
          const greetings = {
            'ru': 'Привет, мир!',
            'en': 'Hello World!',
            'es': '¡Hola Mundo!',
            'fr': 'Bonjour le monde!',
            'de': 'Hallo Welt!',
            'it': 'Ciao Mondo!',
            'zh': '你好，世界！',
            'ja': 'こんにちは世界！'
          };
          
          const welcomeMessages = {
            'ru': 'Добро пожаловать на наш сайт!',
            'en': 'Welcome to our website!',
            'es': '¡Bienvenido a nuestro sitio web!',
            'fr': 'Bienvenue sur notre site!',
            'de': 'Willkommen auf unserer Website!',
            'it': 'Benvenuto nel nostro sito web!',
            'zh': '欢迎访问我们的网站！',
            'ja': '私たちのウェブサイトへようこそ！'
          };
          
          // Получаем код языка (первые 2 символа)
          const langCode = userLang.substring(0, 2);
          
          // Устанавливаем приветствие на языке пользователя или на английском по умолчанию
          greetingElement.textContent = greetings[langCode] || greetings['en'];
          welcomeElement.textContent = welcomeMessages[langCode] || welcomeMessages['en'];
        </script>
      </body>
      </html>
      EOL
      
      # Перезапускаем Nginx
      systemctl restart nginx
    EOF
  }
}

# Создание целевой группы для балансировщика
resource "yandex_alb_target_group" "app_target_group" {
  name = "app-target-group"

  target {
    subnet_id  = yandex_vpc_subnet.app_subnet.id
    ip_address = yandex_compute_instance.web_server_1.network_interface.0.ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.app_subnet.id
    ip_address = yandex_compute_instance.web_server_2.network_interface.0.ip_address
  }
}

# Создание бэкенд-группы для балансировщика
resource "yandex_alb_backend_group" "app_backend_group" {
  name = "app-backend-group-new"  # Изменено имя ресурса в Yandex Cloud

  http_backend {
    name             = "app-http-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.app_target_group.id]
    load_balancing_config {
      panic_threshold = 50
    }
    healthcheck {
      timeout             = "1s"
      interval            = "1s"
      healthcheck_port    = 80
      http_healthcheck {
        path = "/"
      }
    }
  }
}

# Создание HTTP-роутера
resource "yandex_alb_http_router" "app_router" {
  name = "app-http-router"
}

# Создание виртуального хоста
resource "yandex_alb_virtual_host" "app_virtual_host" {
  name           = "app-virtual-host"
  http_router_id = yandex_alb_http_router.app_router.id
  
  route {
    name = "app-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.app_backend_group.id
        timeout          = "60s"
      }
    }
  }
}

# Создание L7-балансировщика нагрузки
resource "yandex_alb_load_balancer" "app_load_balancer" {
  name = "app-load-balancer"

  network_id = yandex_vpc_network.app_network.id
  security_group_ids = [yandex_vpc_security_group.lb_sg.id]

  allocation_policy {
    location {
      zone_id   = var.yc_zone
      subnet_id = yandex_vpc_subnet.app_subnet.id
    }
  }

  listener {
    name = "app-listener"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.app_router.id
      }
    }
  }
}

# Вывод IP-адресов серверов и балансировщика
output "web_server_1_ip" {
  value = yandex_compute_instance.web_server_1.network_interface.0.nat_ip_address
}

output "web_server_2_ip" {
  value = yandex_compute_instance.web_server_2.network_interface.0.nat_ip_address
}

output "load_balancer_ip" {
  value = yandex_alb_load_balancer.app_load_balancer.listener.0.endpoint.0.address.0.external_ipv4_address.0.address
}
