FROM ubuntu:focal

RUN apt-get update && \
  apt-get install -yq curl make ssh apt-transport-https ca-certificates software-properties-common

# Установка Docker CLI
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
RUN apt-get update && \
  apt-get install -yq docker-ce-cli

# Установка Ansible
RUN apt-get update && \
  apt-get install -yq ansible ansible-lint git

# Установка Terraform
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
RUN apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
RUN apt update && apt install -yq terraform

WORKDIR /project

COPY . .
