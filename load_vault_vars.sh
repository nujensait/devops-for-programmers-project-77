#!/bin/bash

# Проверяем, установлен ли ansible-vault
if ! command -v ansible-vault &> /dev/null; then
    echo "Ошибка: ansible-vault не найден. Убедитесь, что Ansible установлен."
    echo "Установите Ansible: pip install ansible"
    exit 1
fi

# Путь к файлу backend.tfvars
BACKEND_TFVARS="terraform/backend.tfvars"

# Создаем файл backend.tfvars
echo "# Автоматически сгенерировано из ansible/vault.yml" > "$BACKEND_TFVARS"
echo "# Не редактируйте этот файл вручную" >> "$BACKEND_TFVARS"

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
        
        # Экспортируем переменную для Terraform
        export "TF_VAR_${clean_key}=${clean_value}"
        echo "Экспортирована переменная: TF_VAR_${clean_key}"
        
        # Если это ключи доступа S3, добавляем их в backend.tfvars без двойных кавычек
        if [ "$clean_key" = "s3_access_key" ]; then
            echo "access_key = ${clean_value}" >> "$BACKEND_TFVARS"
        fi
        
        if [ "$clean_key" = "s3_secret_key" ]; then
            echo "secret_key = ${clean_value}" >> "$BACKEND_TFVARS"
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

# Проверяем, что файл backend.tfvars создан правильно
if [ -f "$BACKEND_TFVARS" ]; then
    # Исправляем возможные проблемы с кавычками в файле
    sed -i 's/""/"/' "$BACKEND_TFVARS"
    echo "Файл backend.tfvars создан и проверен"
else
    echo "Ошибка: файл backend.tfvars не был создан"
    exit 1
fi

echo "Переменные успешно загружены"
