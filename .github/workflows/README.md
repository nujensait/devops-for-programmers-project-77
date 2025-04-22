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

## Automatic tests

After completing all the steps in the project, automatic tests will become available to you. Tests are run on each commit - once all tasks in the Hexlet interface are completed, make a commit, and the tests will run automatically.

The hexlet-check.yml file is responsible for running these tests - do not delete this file, edit it, or rename the repository.

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
