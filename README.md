# ansible-web-wm
Ansible projekt pro nasazení webového serveru

## Ansible Web Server — Projekt `ansible-web-wm`
Komplexní automatizace Linux serveru pomocí **Ansible**, zaměřená na:
- bezpečnostní konfiguraci (firewall, fail2ban, ssh)
- automatické aktualizace systému
- vytvoření dedikovaného uživatele `webapp`
- nasazení jednoduchého webserveru
- použití `ansible-vault` pro šifrování citlivých údajů

---
## Struktura projektu
kořenová složka ansible-web-wm
- inventory/hosts.ini
- playbooks/webserver.yml
- roles/users
- roles/webserver
- roles/firewall
- roles/ssh
- roles/updates
- group_vars/web/vault (zašifrovaný soubor s heslem)

---
## Spuštění
Před prvním spuštěním nastav cestu k rolím (v `provision.sh` už připraveno):
```bash
export ANSIBLE_ROLES_PATH="./roles"
```
Spusť provisioning:
./provision.sh
Alternativně:
ansible-playbook -i inventory/hosts.ini playbooks/webserver.yml --ask-vault-pass
Heslo k Vaultu zadej při výzvě (tajemstvi123).

## Ansible Vault — Bezpečné uchování hesla
Citlivé heslo je zašifrováno pomocí ansible-vault:
ansible-vault encrypt group_vars/web/vault
Proměnná:
webapp_password: "tajneheslo123"
Použita v roli users:
- name: Create dedicated user webapp with password from Vault
  user:
    name: webapp
    password: "{{ webapp_password | password_hash('sha512') }}"
    shell: /bin/bash
    state: present
Vault je výslovně načten v playbooku:
vars_files:
  - ../group_vars/web/vault

## Další bezpečnostní prvky
fail2ban je nainstalován a aktivován pomocí úkolu:
- name: Enable fail2ban service
  service:
    name: fail2ban
    enabled: true
SSH konfigurace zabezpečuje přihlášení (např. zakázání root logování)
Firewall nastavuje povolené porty (např. 22, 80)

## Bonusové funkce
Automatické bezpečnostní aktualizace:
- name: Enable automatic security updates
  copy:
    dest: /etc/apt/apt.conf.d/20auto-upgrades
Webová aplikace dostupná na portu 80
Uživatel webapp vytvořen pomocí hesla z Vaultu

## Stav projektu
Správa uživatelů        Ano
Zabezpečení systému     Ano
Aktualizace systému     Ano
Webserver               Ano
Vault (heslo)           Ano
Provisioning            Ano, bez chyby

## Autor
Projekt vypracovala Michaela Kučerová
Verze: 1.0
Datum: červenec 2025
