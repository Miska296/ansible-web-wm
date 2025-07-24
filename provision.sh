#!/bin/bash

echo "Spouštím provisioning..."

# Aktualizace systému
sudo apt update && sudo apt upgrade -y

# Instalace závislostí
sudo apt install -y ansible git ssh

# Nastavit cestu k rolím
export ANSIBLE_ROLES_PATH="./roles"

# Spuštění playbooku
ansible-playbook -i inventory/hosts.ini playbooks/webserver.yml

echo "Provisioning dokončen!"
