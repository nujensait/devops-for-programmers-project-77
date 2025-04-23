# DataDog Monitor для проверки доступности приложения
resource "datadog_monitor" "app_availability" {
  name               = "App Availability Check"
  type               = "service check"
  message            = "Приложение недоступно на сервере {{host.name}}. @devops@example.com"
  escalation_message = "Приложение все еще недоступно! Требуется немедленное вмешательство! @devops@example.com"

  query = "\"http.can_connect\".over(\"instance:App Status\").by(\"host\").last(3).count_by_status()"

  monitor_thresholds {
    critical = 3
    warning  = 2
    ok       = 1
  }

  notify_no_data    = true
  no_data_timeframe = 10
  renotify_interval = 60

  include_tags = true
  
  tags = [
    "app:web-app",
    "env:production",
    "service:http",
    "team:devops"
  ]
}

# DataDog Synthetics Test для проверки доступности балансировщика нагрузки
resource "datadog_synthetics_test" "load_balancer_test" {
  name      = "Load Balancer Availability"
  type      = "api"
  subtype   = "http"
  status    = "live"
  message   = "Балансировщик нагрузки недоступен. @devops@example.com"
  locations = ["aws:eu-central-1"]
  
  request_definition {
    method = "GET"
    url    = "http://${yandex_alb_load_balancer.app_load_balancer.listener.0.endpoint.0.address.0.external_ipv4_address.0.address}"
  }
  
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "200"
  }
  
  options_list {
    tick_every = 300
    
    retry {
      count    = 2
      interval = 300
    }
    
    monitor_options {
      renotify_interval = 120
    }
  }
  
  tags = [
    "app:web-app",
    "env:production",
    "service:load-balancer",
    "team:devops"
  ]
}
