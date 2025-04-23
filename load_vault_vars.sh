#!/bin/bash

# Проверяем, установлен ли ansible-vault
if ! command -v ansible-vault &> /dev/null; then
    echo "Ошибка: ansible-vault не найден. Убедитесь, что Ansible установлен."
    echo "Установите Ansible: pip install ansible"
    exit 1
fi

# Путь к файлу backend.tfvars
BACKEND_TFVARS="terraform/backend.tfvars"
TERRAFORM_TFVARS="terraform/terraform.tfvars"

# Создаем файлы с переменными
echo "# Автоматически сгенерировано из ansible/vault.yml" > "$BACKEND_TFVARS"
echo "# Не редактируйте этот файл вручную" >> "$BACKEND_TFVARS"

echo "# Автоматически сгенерировано из ansible/vault.yml" > "$TERRAFORM_TFVARS"
echo "# Не редактируйте этот файл вручную" >> "$TERRAFORM_TFVARS"

# Загружаем переменные из зашифрованного vault.yml
ansible-vault view ansible/vault.yml --ask-vault-pass | grep -v "^#" | grep -v "^$" | while IFS=: read -r key value; do
    # Удаляем пробелы из ключа и проверяем, что он не содержит недопустимых символов
    clean_key=$(echo "$key" | tr -d ' ' | tr -d '\t')
    
    # Пропускаем строки, начинающиеся с дефисов (комментарии или разделители)
    if [[ "$clean_key" == ---* ]]; then
        echo "Пропускаем строку: $clean_key"
        continue
    fi
    
    # Проверяем, что ключ не пустой и не содержит недопустимых символов
    if [ -n "$clean_key" ] && ! [[ "$clean_key" =~ [^a-zA-Z0-9_] ]]; then
        # Удаляем начальные и конечные пробелы из значения
        clean_value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        
        # Добавляем переменную в terraform.tfvars
        if [ "$clean_key" = "s3_access_key" ]; then
            echo "# s3_access_key = \"${clean_value}\"" >> "$TERRAFORM_TFVARS"
        elif [ "$clean_key" = "s3_secret_key" ]; then
            echo "# s3_secret_key = \"${clean_value}\"" >> "$TERRAFORM_TFVARS"
        else
            # Экранируем кавычки в значении, если они есть
            escaped_value=$(echo "$clean_value" | sed 's/"/\\"/g')
            echo "${clean_key} = \"${escaped_value}\"" >> "$TERRAFORM_TFVARS"
        fi
        
        # Если это ключи доступа S3, добавляем их в backend.tfvars
        if [ "$clean_key" = "s3_access_key" ]; then
            # Экранируем кавычки в значении, если они есть
            escaped_value=$(echo "$clean_value" | sed 's/"/\\"/g')
            echo "access_key = \"${escaped_value}\"" >> "$BACKEND_TFVARS"
        fi
        
        if [ "$clean_key" = "s3_secret_key" ]; then
            # Экранируем кавычки в значении, если они есть
            escaped_value=$(echo "$clean_value" | sed 's/"/\\"/g')
            echo "secret_key = \"${escaped_value}\"" >> "$BACKEND_TFVARS"
        fi
    elif [ -n "$clean_key" ]; then
        echo "Пропускаем переменную с недопустимыми символами: $clean_key"
    fi
done

# Проверяем успешность выполнения
if [ $? -ne 0 ]; then
    echo "Ошибка при загрузке переменных из vault.yml"
    exit 1
fi

# Удаляем существующие файлы terraform.tfvars и backend.tfvars, если они уже существуют
rm -f "$TERRAFORM_TFVARS.tmp" "$BACKEND_TFVARS.tmp" 2>/dev/null

echo "Файл backend.tfvars создан"
echo "Файл terraform.tfvars создан"
echo "Переменные успешно загружены"
