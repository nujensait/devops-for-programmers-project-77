#!/bin/bash

# Проверяем, установлен ли ansible-vault
if ! command -v ansible-vault &> /dev/null; then
    echo "Ошибка: ansible-vault не найден. Убедитесь, что Ansible установлен."
    echo "Установите Ansible: pip install ansible"
    exit 1
fi

# Загружаем переменные из зашифрованного vault.yml
ansible-vault view ansible/vault.yml --ask-vault-pass | grep -v "^#" | grep -v "^$" | while IFS=: read -r key value; do
    # Удаляем пробелы и специальные символы из ключа
    clean_key=$(echo "$key" | tr -d ' ' | tr -d '-' | tr -d '.' | tr -d '/' | tr -d '(' | tr -d ')')
    
    # Проверяем, что ключ не пустой
    if [ -n "$clean_key" ]; then
        # Удаляем начальные пробелы из значения
        clean_value=$(echo "$value" | sed -e 's/^[[:space:]]*//')
        
        # Экспортируем переменную
        export "TF_VAR_${clean_key}=${clean_value}"
        echo "Экспортирована переменная: TF_VAR_${clean_key}"
    fi
done

# Проверяем успешность выполнения
if [ $? -ne 0 ]; then
    echo "Ошибка при загрузке переменных из vault.yml"
    exit 1
fi

echo "Переменные успешно загружены"
