# Настройка мониторинга в Upmon через REST API
# Поскольку официального провайдера Terraform для Upmon нет,
# мы используем null_resource и local-exec provisioner

# Добавляем локальную переменную для URL приложения
locals {
  app_url = "http://${yandex_alb_load_balancer.app_load_balancer.listener.0.endpoint.0.address.0.external_ipv4_address.0.address}"
}

resource "null_resource" "upmon_monitoring" {
  # Выполняем только после создания балансировщика нагрузки
  depends_on = [yandex_alb_load_balancer.app_load_balancer]

  # Триггер для пересоздания ресурса при изменении IP-адреса
  triggers = {
    lb_ip = yandex_alb_load_balancer.app_load_balancer.listener.0.endpoint.0.address.0.external_ipv4_address.0.address
  }

  # Используем curl для отправки запроса к API Upmon
  provisioner "local-exec" {
    command = <<-EOT
      curl -X POST "https://upmon.ru/api/v1/monitors" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${var.upmon_api_key}" \
        -d '{
          "name": "Web Application",
          "url": "${local.app_url}",
          "interval": ${var.upmon_check_interval},
          "type": "http",
          "regions": ["ru"],
          "notifications": {
            "email": true,
            "telegram": true
          }
        }'
    EOT
  }
}
