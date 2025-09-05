#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

echo "Spouštím provisioning..."

# Aktualizace systému
sudo apt update && sudo apt upgrade -y

# Instalace závislostí
sudo apt install -y ansible git ssh

# Nastavit cestu k rolím
export ANSIBLE_ROLES_PATH="./roles"

# Spuštění playbooku s Vault heslem
ansible-playbook -i inventory/hosts.ini playbooks/webserver.yml --ask-vault-pass

echo "Provisioning dokončen!"

echo "Spouštím Nginx..."
if sudo service nginx start; then
    echo "Nginx byl úspěšně spuštěn!"
else
    echo "Nepodařilo se spustit Nginx."
fi
