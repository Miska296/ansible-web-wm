# Ansible Web Server Deployment
---
## 🧾 Projekt: ansible-web-wm
Automatizované nasazení a zabezpečení webového serveru pomocí Ansible v prostředí GitHub Codespace. Projekt zahrnuje konfiguraci SSH, firewallu, aktualizací systému, nasazení statického webu a validaci funkčnosti.

---
## 🚀 Jak spustit provisioning
1. Nastav cestu k rolím:
    ```bash
    export ANSIBLE_ROLES_PATH="./roles"
    ```
2. Spusť provisioning:
    ```bash
    ./provision.sh
    ```
3. Ověř, že NGINX běží:
    ```bash
    curl http://localhost
    ```
4. Otevři veřejnou URL (např. v Codespace): https://fluffy-space-trout-97xpgj6x6qgqf9qq-80.app.github.dev

---
## 🧩 Struktura projektu
inventory/
└── hosts.ini          *(Definice cílového hostitele)*

playbooks/
└── webserver.yml      *(Hlavní playbook)*

roles/
├── users/             *(Vytváření uživatelů)*
├── ssh/               *(Konfigurace SSH)*
├── firewall/          *(UFW + fail2ban)*
├── updates/           *(Systémové aktualizace)*
├── webserver/         *(Instalace a konfigurace NGINX)*
├── validation/        *(Ověření funkčnosti webu)*
└── group_vars/
    └── web/
        └── vault      *(Hesla a proměnné chráněné Vaultem)*

---
## 🔐 Zabezpečení
- SSH:
    - Zakázán root login (`PermitRootLogin no`)
    - Zakázáno heslové přihlášení (`PasswordAuthentication no`)
    - Ansible spravuje `sshd_config` s `--force-confold` pro bezpečné aktualizace

- Firewall (UFW):
    - Povolené porty: `22/tcp`, `80/tcp` (včetně IPv6)
    - Stav ověříte příkazem:
        ```bash
        sudo ufw status
        ```

- Fail2ban:
    - Automatická ochrana proti `brute-force` útokům

---
## 🌐 Webový server
- NGINX:
    - Instalace přes `apt`
    - Konfigurace pomocí šablony `nginx.conf.j2`
    - Root adresář: `/opt/static-sites`
    - Obsah generován ze šablony `index.html.j2`:
        ```html
        <h1>Hello from Ansible-managed NGINX!</h1>
        ```

- Git deploy (volitelně):
    - Repozitář: `static-web-test`
    - Klonuje se do `/opt/static-sites`
    - Přepis `index.html` z šablony zajišťuje validaci

---
## ✅ Validace funkčnosti
Role `validation` ověřuje, že webový server odpovídá správně:
    ```yaml
    - name: Validate web server response
    uri:
        url: http://localhost
        return_content: yes
    register: web_response

    - name: Check that response contains expected text
    assert:
        that:
        - "'Hello from Ansible-managed NGINX!' in web_response.content"
    ```

---
## Nasazení přes Vagrant
### 📦 Alternativní nasazení: Vagrant
Projekt lze spustit i lokálně pomocí Vagrantu, což umožňuje testovat provisioning v izolovaném prostředí.
⚠️ Vagrant nelze spustit v GitHub Codespace. Pro testování použij lokální počítač s nainstalovaným Vagrantem a VirtualBoxem.
- 🔧 Požadavky
    - Vagrant
    - VirtualBox nebo jiný poskytovatel VM

- 📁 Struktura
V kořenovém adresáři projektu se nachází soubor `Vagrantfile`, který definuje virtuální stroj:
    ```ruby
    Vagrant.configure("2") do |config|
        config.vm.box = "ubuntu/jammy64"
        config.vm.network "private_network", ip: "192.168.56.10"
        config.vm.provision "shell", path: "./provision.sh"
    end
    ```

- 🚀 Spuštění
1. Inicializuj a spusť VM:
    ```bash
    vagrant up
    ```
2. Připoj se k VM:
    ```bash
    vagrant ssh
    ```
3. Ověř webový server:
    ```bash
    curl http://localhost
    ```
Nebo z hostitelského systému:
    ```bash
    curl http://192.168.56.10
    ```
4. Zastavení VM:
    ```bash
    vagrant halt
    ```
5. Smazání VM (volitelně):
    ```bash
    vagrant destroy
    ```

- 🧪 Poznámka
Vagrant automaticky spouští `provision.sh`, takže není nutné ho spouštět ručně. Výhodou je, že prostředí je čisté a opakovatelné — ideální pro testování idempotence Ansible playbooku.

---
## 🧠 Bonusové body
- 🔐 Ansible Vault: chrání citlivé proměnné (např. hesla)
- 🔁 Idempotence: opakované spuštění playbooku nezpůsobí chyby
- 🔄 Handlers: restart služeb pouze při změně konfigurace
- 🧪 Debug výpisy: pro ladění obsahu `index.html` a odpovědi serveru

---
## 🧑‍💻 Autor
Michaela Kučerová
Projekt vytvořen a testován v GitHub Codespace