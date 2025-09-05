# ansible-web-wm
Automated deployment and security of a web server using Ansible

---
## Project information
This project serves for automated installation and configuration of a web server using Ansible. It includes:
- Roles for Nginx, Fail2ban, firewall, SSH and automatic updates
- Usage `ansible-vault` for the secure storage of passwords
- Playbooks and scripts `provision.sh` for easy deployment
The project is based on [static-web-test](https://github.com/Miska296/static-web-test), created in the Replit environment, and was significantly enhanced with security features, automation, and system management.
**The project was fully tested — provisioning was completed without errors, all services were successfully validated.**

![Deployment scheme](deployment-diagram.png)

---
## Project: Ansible Web Server `ansible-web-wm`
Comprehensive automation of Linux servers using **Ansible**, focused on:
- security configuration (`firewall`, `fail2ban`, `ssh`)
- automatic system updates
- creation of a dedicated user `webapp`
- deployment of a simple web server
- using `ansible-vault` for encrypting sensitive data

---
## Requirements for the environment
- Python 3.8+
- Ansible 2.10+
- Linux server or VM with SSH access
- Vault password for encrypted variables
- Properly set file `inventory/hosts.ini`
- Installed `sudo` (for running with `become: true`)

---
## Project launch
1. **Optional: Cloning the repository**
   If you haven't downloaded the repository yet:
   ```bash
   git clone https://github.com/Miska296/ansible-web-wm.git
   cd ansible-web-wm
   ```
2. Setting the paths to roles (already prepared in provision.sh):
   ```bash
   export ANSIBLE_ROLES_PATH="./roles"
   ```
3. Starting the provisioning:
   ```bash
   ./provision.sh
   ```
4. After launching, enter the password for the Vault when prompted.
5. Check the functionality of the web server: 
Open in your browser `http://localhost` or the corresponding IP address — a page with the text should appear:
Hello from GitHub!
This file was uploaded by Michaela for Ansible testing.

---
## Ansible Vault — Safe storage of password
- The sensitive password has been encrypted using `ansible-vault`:
   ```bash
   ansible-vault encrypt group_vars/web/vault
   ```
- Variable:
   ```yaml
   webapp_password: "tajneheslo123"
   ```
- Used in the role of `users`:
   ```yaml
   - name: Create dedicated user webapp with password from Vault
   user:
      name: webapp
      password: "{{ webapp_password | password_hash('sha512') }}"
      shell: /bin/bash
      state: present
   ```
- The vault is explicitly loaded in the playbook:
   ```yaml
   vars_files:
   - ../group_vars/web/vault
   ```

---
## Additional safety features
- `fail2ban` is installed and activated:
   ```yaml
   - name: Enable fail2ban service
   service:
      name: fail2ban
      enabled: true
   ```
- SSH is secured (e.g. disabling root login)
- The firewall protects the server and only allows necessary ports (e.g., 22, 80)

---
## Project structure
root component `ansible-web-wm`:
- inventory/hosts.ini
- playbooks/webserver.yml
- roles/users
- roles/webserver
- roles/firewall
- roles/ssh
- roles/updates
- group_vars/web/vault *(encrypted file with a password)*
- provision.sh
- README.md

![Structure of folders](screenshots/project-structure.png)
*Project structure in Codespace*

## Bonus features
- Automatic security updates:
   ```yaml
   - name: Enable automatic security updates
     copy:
       dest: /etc/apt/apt.conf.d/20auto-upgrade
   ```
- Web application available on port 80
- Webapp user created using a password from the Vault

## Project status
- **User management** — Yes
- **Password Vault** — Yes
- **Security (firewall, fail2ban, ssh)** — Yes
- **Automatic updates** — Yes
- **Webserver** — Yes
- **Provisioning** — Yes, without mistakes

## Testing and verification of functionality
After completing the provisioning, please perform the following checks:
- **Webserver is running:**
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
- The Ansible playbook ran without errors:
Watch the output in the terminal – `failed=0` confirms success.

![Provisioning output](screenshots/provisioning-output.png)
*Successful completion of provisioning (`failed=0`)*

The web page has been successfully deployed and is available at the public address in GitHub Codespace: 
[glowing-barnacle-q7xw5pvxvv4jhx6jg-80.app.github.dev](https://glowing-barnacle-q7xw5pvxvv4jhx6jg-80.app.github.dev/)

![Website preview](screenshots/web-preview.png)
*Displayed page after deploying NGINX*

---
## Video presentation of the project
It shows the complete run of the script `provision.sh`, deployment of a web server using Ansible and verification of functionality.

[![Presentation of the ansible-web-wm project](https://img.youtube.com/vi/aNvzjHr_p9I/0.jpg)](https://www.youtube.com/watch?v=aNvzjHr_p9I&t=3s)

---
## Related project
This project is based on the original repository [static-web-test](https://github.com/Karan-Negi-12/Static-website-for-testing), where a static web application was created using the Replit platform. The project `ansible-web-wm` has been supplemented with automation, security features, and extensive testing.

---
## Troubleshooting
### 1. No port has opened
If ports 22 (SSH) or 80 (HTTP) are not open after provisioning, please check the following:
1. **Firewall (UFW)**  
   Check the status of the firewall:
   ```bash
   sudo ufw status
   ```
- If active, allow the necessary ports:
   ```bash
   sudo ufw allow 22
   sudo ufw allow 80
   sudo ufw reload
   ```

### 2. Ports are not available in Codespace
If ports 22 or 80 are not visible in the 'Ports' tab:
1. Open the **Ports** tab in Codespace
2. Click on **"Add port"**
3. Enter `80` and check **'Public'**
4. After saving, a public URL will be displayed, e.g. `https://username-repo-80.app.github.dev`
5. Open it in the browser and verify that the page loads
6. Check that NGINX is listening on all interfaces (`listen 80`, `listen [::]:80`)

### 3. NGINX is running but is not accessible.
   Check the status of the service:
   ```bash
   systemctl status nginx
   ```
   Check if it is listening on port 80:
   ```bash
   ss -tuln | grep :80
   ```

### 4. SSH access restricted
Pokud jste zakázali přihlášení pomocí hesla nebo root uživatele, ujistěte se, že máte správně nastavený SSH klíč v `sshd_config`.

### 5. Provisioning proběhl, ale změny se neprojevily
   Zkuste provisioning spustit znovu:
   ```bash
   ./provision.sh
   ```

### 6. Web není dostupný zvenčí
Pokud se webová stránka nezobrazuje přes veřejnou URL (např. v Codespace), zkontrolujte:
1. **Konfiguraci NGINX**
   - Ujistěte se, že v šabloně `nginx.conf.j2` je:
     ```nginx
     server_name _;
     listen 80;
     listen [::]:80;
     ```
   - Tím zajistíte, že server naslouchá na všech rozhraních a není omezen na `localhost`.
2. **Restart služby**
   - V prostředí bez `systemd` použijte:
     ```bash
     service nginx restart
     ```
3. **Zveřejnění portu**
   - V Codespace ručně přidejte port 80 v záložce „Ports“ a nastavte ho jako „Public“.
4. **Firewall**
   - Ověřte, že porty 22 a 80 jsou povolené:
     ```bash
     sudo ufw status
     ```

---
## Osvědčené postupy (Best Practices)
- Používejte `DEBIAN_FRONTEND=noninteractive` pro potlačení interaktivních dotazů při instalaci balíčků.
- Využívejte `ansible-vault` pro bezpečné uchování citlivých údajů.
- Po každém provisioning ověřte stav služeb (`nginx`, `fail2ban`, `ssh`) a otevřené porty.
- Používejte `server_name _` v konfiguraci NGINX, pokud chcete, aby server reagoval na požadavky z libovolné domény nebo IP adresy.  
  → `server_name localhost` omezuje přístup pouze na místní stroj, což může blokovat přístup v prostředích jako Codespaces nebo při testování zvenčí.
- Přidejte `listen [::]:80;` pro podporu IPv6, což zvyšuje dostupnost v moderních sítích.
- Po každé změně konfigurace NGINX spusťte provisioning znovu a ověřte stav služby.
- Dokumentujte strukturu projektu, diagram nasazení a výstupy provisioning.
- Udržujte čistou strukturu repozitáře — vyhněte se zanořeným složkám.

---
## Autor
Projekt vypracovala Michaela Kučerová
Verze: 1.0
Datum: červenec 2025

---
## Licence  
Tento projekt je dostupný pod licencí MIT. Viz soubor [LICENSE](LICENSE).
