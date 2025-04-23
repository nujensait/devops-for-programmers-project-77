# Makefile для DevOps проекта (WSL, Terraform, Ansible)

.PHONY: help setup tf-init tf-plan tf-apply tf-destroy ansible-deps ansible-play deploy clean

help:  ## Показать эту справку
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

## --- Terraform ---
tf-init: ## Инициализировать Terraform
	cd terraform && terraform init

tf-plan: ## Планирование 
	cd terraform && terraform plan

tf-apply: ## Применение
	cd terraform && terraform apply

tf-destroy:  ## Уничтожить инфраструктуру
	cd terraform && terraform destroy

## --- Ansible ---
ansible-deps:  ## Установить зависимости Ansible
	ansible-galaxy install -r ansible/requirements.yml

ansible-play:  ## Запустить Ansible playbook
	ansible-playbook -i ansible/inventory.yml ansible/playbook.yml

## --- Общие команды ---
setup: tf-init ansible-deps  ## Инициализировать проект (Terraform + Ansible)
deploy: tf-apply ansible-play  ## Развернуть инфраструктуру и применить конфигурацию
clean: tf-destroy  ## Удалить всю инфраструктуру
