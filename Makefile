# Makefile для DevOps проекта (WSL, Terraform, Ansible)

.PHONY: help
help:  ## Показать эту справку
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

## --- WSL Управление ---
wsl-shutdown:  ## Остановить WSL
	wsl --shutdown

wsl-update:  ## Обновить WSL
	wsl --update

wsl-restart-service:  ## Перезапустить службу LxssManager
	Get-Service LxssManager | Restart-Service -Force

wsl-reset-network:  ## Сбросить сетевые настройки
	wsl --shutdown
	netsh winsock reset
	netsh int ip reset all
	@echo "Перезагрузите компьютер после выполнения этих команд"

wsl-reinstall:  ## Переустановить WSL (сбросить)
	wsl --unregister Ubuntu
	wsl --install -d Ubuntu

## --- Yandex Cloud / Vault ---

load-vars: ## Загрузить переменные из vault.yml
	./load_vault_vars.sh

tf-plan: load-vars ## Планирование с загруженными переменными
	cd terraform && terraform plan

tf-apply: load-vars ## Применение с загруженными переменными
	cd terraform && terraform apply

## --- Terraform ---
tf-init:  ## Инициализировать Terraform
	cd terraform && terraform init

tf-plan:  ## Планирование изменений
	cd terraform && terraform plan

tf-apply:  ## Применить изменения
	cd terraform && terraform apply

tf-destroy:  ## Уничтожить инфраструктуру
	cd terraform && terraform destroy

## --- Ansible ---
ansible-vault-edit:  ## Редактировать зашифрованный файл с переменными
	ansible-vault edit ansible/vault.yml

ansible-play:  ## Запустить Ansible playbook
	ansible-playbook ansible/playbook.yml --ask-vault-pass

## --- Общие команды ---
setup: tf-init  ## Инициализировать проект (Terraform + Ansible)
deploy: tf-apply ansible-play  ## Развернуть инфраструктуру и применить конфигурацию
clean: tf-destroy  ## Удалить всю инфраструктуру
