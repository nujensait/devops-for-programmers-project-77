# Table of Contents
1. [About this project](#about-this-project)
2. [Hexlet tests status](#hexlet-tests-and-linter-status)
3. [Project structure](#project-structure)
4. [Contacts](#contacts)

-----

## About this project
- Hexlet's course: ["DevOps for Programmers"](https://lite.al/VpBen)
- Project #3: Infrastructure as code (Terraform)

----

## Hexlet tests and linter status
[![Actions Status](https://github.com/nujensait/devops-for-programmers-project-77/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/nujensait/devops-for-programmers-project-77/actions)

-----

## Project structure

```bash
your_project/
├── terraform/          # Инфраструктура как код (Terraform)
│   ├── provider.tf     # Конфигурация провайдера Yandex Cloud
│   ├── backend.tf      # Конфигурация удалённого бэкенда (S3)
│   ├── main.tf         # Основные ресурсы (VM, сети и т. д.)
│   └── variables.tf    # Переменные (несекретные)
├── ansible/            # Конфигурация серверов (Ansible)
│   ├── playbook.yml    # Основной плейбук
│   └── vault.yml       # Зашифрованные переменные (Ansible Vault)
└── README.md           # Описание проекта
```

## Contacts

- Author: Mikhail Ikonnikov <mishaikon@gmail.com>

----
