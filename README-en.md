# Ansible Web Server Deployment

![MIT License](https://img.shields.io/badge/license-MIT-green.svg)
![Last Updated](https://img.shields.io/badge/last--updated-September%202025-blue)
![Build](https://img.shields.io/badge/build-OK-brightgreen)
![GitHub Pages](https://img.shields.io/badge/GitHub--Pages-Live-green)

Automated deployment and securing of a web server using Ansible in a GitHub Codespace environment. The project includes configuration of SSH, firewall, system updates, deployment of a static website, and functionality validation.
> This project is also available in the Czech version: [README-en.md](README-en.md)

---
---
# Introduction part
## 1. Information about the project
This project is used for automated installation and configuration of a web server using Ansible.
It includes:
- Roles for Nginx, Fail2ban, firewall, SSH, and automatic updates
- Usage `ansible-vault` for the secure storage of passwords
- Playbooks and scripts `provision.sh` for easy deployment

The project is based on [static-web-test](https://github.com/Miska296/static-web-test), created in the Replit environment, and has been significantly enhanced with security features, automation, and system management.
**The project has been fully tested - the provisioning was completed without errors, all services have been successfully verified.**

![Deployment scheme](deployment-diagram.png)

---
## 2. Project: Ansible Web Server `ansible-web-wm`
Comprehensive automation of a Linux server using **Ansible**, focused on:
- security configuration (`firewall`, `fail2ban`, `ssh`)
- automatic system updates
- creation of a dedicated user `webapp`
- deployment of a simple web server
- use `ansible-vault` for encrypting sensitive data

---
## 3. Requirements for the environment
- Python 3.8+
- Ansible 2.10+
- Linux server or VM with SSH access
- Vault password for encrypted variables
- Correctly configured file `inventory/hosts.ini`
- Installed `sudo` (for running with `become: true`)

---
---
# Deployment and configuration
## 4. Project structure
root component `ansible-web-wm/`:
- inventory/hosts.ini      *(Definition of the target host)*  

- playbooks/webserver.yml  *(Main playbook)*

- roles/users              *(Creating users)*
- roles/ssh                *(SSH configuration)*
- roles/firewall           *(UFW + fail2ban)*
- roles/updates            *(System updates)*
- roles/webserver          *(Installation and configuration of NGINX)*
- roles/validation         *(Verification of the website's functionality)*
- group_vars/web/vault     *(Passwords and variables protected by Vault)*

- provision.sh
- README.md

![Structure of components](screenshots/project-structure.png)
*Project structure in Codespace*

---
## 5. Project launch
1. **Optional: Cloning the repository**  
   If you haven't downloaded the repository yet:
   ```bash
   git clone https://github.com/Miska296/ansible-web-wm.git
   cd ansible-web-wm
   ```
2. Setting paths to roles (already prepared in provision.sh):
   ```bash
   export ANSIBLE_ROLES_PATH="./roles"
   ```
3. Starting the provisioning:
   ```bash
   ./provision.sh
   ```
4. After starting, enter the password for the Vault when prompted.
5. Check that NGINX is running:
    ```bash
    curl http://localhost
    ```
6. Open the public URL (e.g., in Codespace): https://fluffy-space-trout-97xpgj6x6qgqf9qq-80.app.github.dev
7. Check the functionality of the web server:  
Open in the browser `http://localhost` or a public URL - a page with the following content should be displayed:
   ```html
   <h1>Hello from Ansible-managed NGINX!</h1>
   <p>Server configured automatically by michaela using Ansible</p>
   ```
*This text must be included in the output for the validation to be successful.*

---
## 6. Ansible Vault – Secure Storage of Passwords
- The sensitive password was encrypted using `ansible-vault`:
   ```bash
   ansible-vault encrypt group_vars/web/vault
   ```
- Variable:
   ```yaml
   webapp_password: "tajneheslo123"
   ```
- Used in the role `users`:
   ```yaml
   - name: Create dedicated user webapp with password from Vault
   user:
      name: webapp
      password: "{{ webapp_password | password_hash('sha512') }}"
      shell: /bin/bash
      state: present
   ```
- Vault is explicitly loaded in the playbook:
   ```yaml
   vars_files:
   - ../group_vars/web/vault
   ```

---
## 7. Additional safety features
- SSH security:
   - Root login prohibited (`PermitRootLogin no`)
   - Password login is prohibited (`PasswordAuthentication no`)
   - Ansible manages `sshd_config` with `--force-confold` for safe updates.

- Firewall (UFW) protects the server and only allows necessary ports:
   - Allowed ports: `22/tcp`, `80/tcp` (including IPv6)
   - You can verify the status with the command:
      ```bash
      sudo ufw status
      ```

- Fail2ban is installed and activated:
   - Automatic protection against `brute-force` attacks
      ```yaml
      - name: Enable fail2ban service
      service:
         name: fail2ban
         enabled: true
      ```

---
## 8. Web server
- NGINX:
   - Installation via `apt`
   - Configuration using the template `nginx.conf.j2`
   - Root directory: `/opt/static-sites`
   - Content generated from the template `index.html.j2`:
      ```html
      <h1>Hello from Ansible-managed NGINX!</h1>
      <p>Server configured automatically by michaela using Ansible</p>
      ```

- Git deploy (optional):
   - Repository: `static-web-test`
   - It is being cloned to `/opt/static-sites`
   - The rewriting of `index.html` from the template ensures validation.

---
---
# Verification and testing
## 9. Functionality validation
The `validation` role verifies that the web server responds correctly. At the end of the main playbook, an HTTP test is performed using the `uri` module, which checks whether the page contains the expected text:
  
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
## 10. Testing and verification of functionality
After completing the provisioning, please perform the following checks:
- **Web server is running:**
   ```bash
   systemctl status nginx
   ```
- Open ports:
   ```bash
   ss -tuln | grep :80
   ```
- The firewall does not block communication:
   ```bash
   ufw status
   ```
- Fail2ban protects the server:
   ```bash
   fail2ban-client status
   ```
- Ansible playbook ran without errors: 
Watch the output in the terminal – `failed=0` confirms success.

![Provisioning output](screenshots/provisioning-output.png)
*Successful completion of provisioning (`failed=0`)*

The webpage has been successfully deployed and is available at the public address in GitHub Codespace:  
[fluffy-space-trout-97xpgj6x6qgqf9qq-80.app.github.dev](https://fluffy-space-trout-97xpgj6x6qgqf9qq-80.app.github.dev/)

> **Notice:** The public URL works only after successful provisioning and the publishing of port 80 in the Codespace.

![Preview of the webpage](screenshots/web-preview.png)
*The displayed page after deploying NGINX*

---
## 11. Problem solving (troubleshooting)
This section contains the most common errors that may occur during the deployment of a project and their solutions. I recommend going through it if the provisioning was completed without errors, but the result is not as expected.

### 1. No port was opened
If ports 22 (SSH) or 80 (HTTP) are not open after provisioning, please check the following:
1. **Firewall (UFW)**  
   Check the status of the firewall:
   ```bash
   sudo ufw status
   ```
- If active, enable the necessary ports:
   ```bash
   sudo ufw allow 22
   sudo ufw allow 80
   sudo ufw reload
   ```

### 2. Ports are not available in Codespace.
If ports 22 or 80 are not visible in the 'Ports' tab:
1. Open the **Ports** tab in Codespace
2. Click on **"Add port"**
3. Enter `80` and check **"Public"**
4. After saving, a public URL will be displayed, for example:  
`https://fluffy-space-trout-97xpgj6x6qgqf9qq-80.app.github.dev/`  
> *Note: The URL is generated automatically based on the name of the Codespace. Your link will have a different format.*
5. Open it in the browser and verify that the page loads
6. Verify that NGINX is listening on all interfaces (`listen 80`, `listen [::]:80`)

### 3. NGINX is running, but is not accessible
   Check the service status:
   ```bash
   systemctl status nginx
   ```
   Check if it is listening on port 80:
   ```bash
   ss -tuln | grep :80
   ```

### 4. SSH access restricted
If you have disabled password login or root user, make sure you have the SSH key correctly set up in `sshd_config`.

### 5. Provisioning was completed, but the changes did not take effect
   Try to run the provisioning again:
   ```bash
   ./provision.sh
   ```

### 6. The web is not accessible from the outside
If the webpage is not displaying through a public URL (e.g., in Codespace), check:
1. **NGINX configuration**
   - Make sure that in the template `nginx.conf.j2` there is:
     ```nginx
     server_name _;
     listen 80;
     listen [::]:80;
     ```
   - This ensures that the server listens on all interfaces and is not limited to `localhost`.
2. **Restart the service**
   - In an environment without `systemd`, use:
     ```bash
     service nginx restart
     ```
3. **Port publishing**
   - Manually add port `80` in the tab in Codespace „Ports“ and set it as „Public“.
4. **Firewall**
   - Verify that ports `22` and `80` are enabled:
     ```bash
     sudo ufw status
     ```

---
## 12. Project status
- **User management** — Yes
- **Password vault** — Yes
- **Security (SSH, firewall, Fail2ban)** — Yes
- **Automatic system updates** — Yes
- **Webserver (NGINX + Git deploy)** — Yes
- **Functionality validation** — Yes
- **Provisioning script** — Yes, without mistakes
- **Deployment via Vagrant** — Yes

> **Live demonstration:** [View project on GitHub Pages](https://miska296.github.io/ansible-web-wm/)

---
---
# Extension and documentation
## 13. Bonusové funkce
Projekt obsahuje několik pokročilých funkcí, které zvyšují bezpečnost, spolehlivost a přehlednost nasazení:

- Automatické bezpečnostní aktualizace:
   ```yaml
   - name: Enable automatic security updates
     copy:
       dest: /etc/apt/apt.conf.d/20auto-upgrades
   ```
- Webová aplikace dostupná na portu `80`
- Uživatel `webapp` vytvořen pomocí hesla z Vaultu
- Ansible Vault: chrání citlivé proměnné (např. hesla)
- Idempotence: opakované spuštění playbooku nezpůsobí chyby
- Handlers: restart služeb pouze při změně konfigurace
- Debug výpisy: pro ladění obsahu `index.html` a odpovědi serveru

---
## 14. Nasazení přes Vagrant
### 14.1 Alternativní nasazení: Vagrant
Projekt lze spustit i lokálně pomocí Vagrantu, což umožňuje testovat provisioning v izolovaném prostředí.
> Soubor `Vagrantfile` je již součástí projektu a připraven k použití.  

⚠️ Vagrant nelze spustit v GitHub Codespace. Pro testování použij lokální počítač s nainstalovaným Vagrantem a VirtualBoxem.

- Požadavky:
   - Vagrant
   - VirtualBox nebo jiný poskytovatel VM

- Struktura:  
V kořenovém adresáři projektu se nachází soubor `Vagrantfile`, který definuje virtuální stroj:
    ```ruby
    Vagrant.configure("2") do |config|
        config.vm.box = "ubuntu/jammy64"
        config.vm.network "private_network", ip: "192.168.56.10"
        config.vm.provision "shell", path: "./provision.sh"
    end
    ```

- Spuštění:
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

- Poznámka:  
Vagrant automaticky spouští `provision.sh`, takže není nutné ho spouštět ručně. Výhodou je, že prostředí je čisté a opakovatelné — ideální pro testování idempotence Ansible playbooku.

---
### 14.2 Další informace o testování nasazení přes Vagrant:
Testování provisioning procesu proběhlo také v samostatném repozitáři [vagrant-nginx-provisioning](https://github.com/Miska296/vagrant-nginx-provisioning), kde byly provedeny drobné úpravy souborů a kódu pro správné fungování v prostředí Vagrant. Tento repozitář slouží jako izolované testovací prostředí, které umožňuje ověřit funkčnost playbooku bez ovlivnění hlavního projektu `ansible-web-wm`.

Provisioning byl následně ověřen i v GitHub Codespace po instalaci Ansible, čímž byla potvrzena kompatibilita obou prostředí.

---
## 15. Osvědčené postupy
Doporučení pro správu projektu, konfiguraci služeb a udržení čisté struktury:

- Používejte `DEBIAN_FRONTEND=noninteractive` pro potlačení interaktivních dotazů při instalaci balíčků.
- Využívejte `ansible-vault` pro bezpečné uchování citlivých údajů.
- Po každém provisioning ověřte stav služeb (`nginx`, `fail2ban`, `ssh`) a otevřené porty.
- Používejte `server_name _` v konfiguraci NGINX, pokud chcete, aby server reagoval na požadavky z libovolné domény nebo IP adresy. → `server_name localhost` omezuje přístup pouze na místní stroj, což může blokovat přístup v prostředích jako Codespaces nebo při testování zvenčí.
- Přidejte `listen [::]:80;` pro podporu IPv6, což zvyšuje dostupnost v moderních sítích.
- Po každé změně konfigurace NGINX spusťte provisioning znovu a ověřte stav služby.
- Dokumentujte strukturu projektu, diagram nasazení a výstupy provisioning.
- Udržujte čistou strukturu repozitáře — vyhněte se zanořeným složkám.

---
## 16. Budoucí vylepšení
- Přidání automatizovaného testování pomocí GitHub Actions
- Vytvoření dynamického webového rozhraní pro provisioning
- Přidání podpory pro nasazení na bázi Dockeru
- Implementování logování a monitorování (např. Prometheus, Grafana)
- Přeložení dokumentace do dalších jazyků
> Tato sekce slouží jako roadmapa pro další vývoj projektu.

---
---
# Kontext a závěr
## 17. Související projekt
Tento projekt vychází z původního repozitáře [static-web-test](https://github.com/Miska296/static-web-test), kde byla vytvořena statická webová aplikace pomocí platformy Replit.
V projektu `ansible-web-wm` byla doplněna automatizace, bezpečnostní prvky a rozsáhlé testování.

---
## 18. Video prezentace projektu
Ukazuje kompletní běh skriptu `provision.sh`, nasazení webového serveru pomocí Ansible a ověření funkčnosti.

[![Prezentace projektu ansible-web-wm](https://img.youtube.com/vi/aNvzjHr_p9I/0.jpg)](https://www.youtube.com/watch?v=aNvzjHr_p9I&t=3s)

---
## 19. Autor
Projekt vypracovala [Michaela Kučerová](https://github.com/Miska296)  
**Verze:** 1.0  
**Datum:** červenec 2025  
**Poslední aktualizace:** September 2025  
**Build:** OK

---
## 20. Licence
Tento projekt je dostupný pod licencí MIT. Podrobnosti viz soubor [LICENSE](LICENSE).