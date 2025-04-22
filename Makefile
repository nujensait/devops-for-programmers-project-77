# Makefile для DevOps проекта (WSL, Terraform, Ansible)

.PHONY: help setup code-setup tf-init tf-plan tf-apply tf-destroy ansible-vault-edit ansible-play deploy clean

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

## --- Ya Cloud cmds ~ Terraform ---

load-vars: ## Загрузить переменные из vault.yml
	./load_vault_vars.sh

tf-init:  ## Инициализировать Terraform
	terraform -chdir=code/terraform init

tf-plan: load-vars ## Планирование с загруженными переменными
	terraform -chdir=code/terraform plan

tf-apply: load-vars ## Применение с загруженными переменными
	terraform -chdir=code/terraform apply

tf-destroy:  ## Уничтожить инфраструктуру
	terraform -chdir=code/terraform destroy

## --- Ansible ---
ansible-vault-edit:  ## Редактировать зашифрованный файл с переменными
	ansible-vault edit ansible/vault.yml

ansible-play:  ## Запустить Ansible playbook
	ansible-playbook ansible/playbook.yml --ask-vault-pass

## --- Hexlet проверки ---
code-setup:  ## Установить зависимости для тестов Hexlet
	cd code/ansible && ansible-galaxy collection install -r requirements.yml

## --- Общие команды ---
setup: tf-init code-setup ## Инициализировать проект (Terraform + Ansible)
deploy: tf-apply ansible-play  ## Развернуть инфраструктуру и применить конфигурацию
clean: tf-destroy  ## Удалить всю инфраструктуру
