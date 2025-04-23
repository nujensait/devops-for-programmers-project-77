#!/bin/bash

# Получаем IP-адреса серверов из Terraform
cd terraform
WEB_SERVER_1_IP=$(terraform output -raw web_server_1_ip)
WEB_SERVER_2_IP=$(terraform output -raw web_server_2_ip)
cd ..

# Экспортируем переменные для Ansible
export WEB_SERVER_1_IP
export WEB_SERVER_2_IP

echo "Web Server 1 IP: $WEB_SERVER_1_IP"
echo "Web Server 2 IP: $WEB_SERVER_2_IP"

# Устанавливаем зависимости Ansible
ansible-galaxy install -r ansible/requirements.yml

# Запускаем Ansible playbook
ansible-playbook -i ansible/inventory.yml ansible/playbook.yml --ask-vault-pass "$@"
