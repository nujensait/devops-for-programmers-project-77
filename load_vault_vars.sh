#!/bin/bash

# Загружаем переменные из зашифрованного vault.yml
eval $(ansible-vault view ansible/vault.yml --ask-vault-pass | \
  awk '/^[^#]/ {gsub(/:/,""); print "export TF_VAR_"$1"="$2}')
