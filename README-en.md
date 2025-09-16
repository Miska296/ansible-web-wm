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
- LICENSE
- README.md
- README-en.md
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
## 13. Bonus features
The project includes several advanced features that enhance the security, reliability, and clarity of the deployment:

- Automatic security updates:
   ```yaml
   - name: Enable automatic security updates
     copy:
       dest: /etc/apt/apt.conf.d/20auto-upgrades
   ```
- Web application available on port `80`
- User `webapp` created using a password from the Vault
- Ansible Vault: protects sensitive variables (e.g., passwords)
- Idempotence: running the playbook repeatedly will not cause errors.
- Handlers: restart services only when the configuration changes
- Debug outputs: for debugging the content of `index.html` and the server response

---
## 14. Deployment via Vagrant
### 14.1 Alternative deployment: Vagrant
The project can also be run locally using Vagrant, which allows for testing provisioning in an isolated environment.
> The `Vagrantfile` is already part of the project and ready for use.  

⚠️ Vagrant cannot be run in GitHub Codespace. For testing, use a local computer with Vagrant and VirtualBox installed.

- Requirements:
   - Vagrant
   - VirtualBox or another VM provider

- Structure:  
In the root directory of the project, there is a file `Vagrantfile` that defines the virtual machine:
    ```ruby
    Vagrant.configure("2") do |config|
        config.vm.box = "ubuntu/jammy64"
        config.vm.network "private_network", ip: "192.168.56.10"
        config.vm.provision "shell", path: "./provision.sh"
    end
    ```

- Launch:
   1. Initialize and start the VM:
      ```bash
      vagrant up
      ```
   2. Join the VM:
      ```bash
      vagrant ssh
      ```
   3. Verify the web server:
      ```bash
      curl http://localhost
      ```
      Or from the host system:  
      ```bash  
      curl http://192.168.56.10  
      ```  
   4. Stopping the VM:  
      ```bash
      vagrant halt
      ```  
   5. VM deletion (optional):  
      ```bash
      vagrant destroy
      ```

- Note:  
Vagrant automatically runs `provision.sh`, so it's not necessary to run it manually. The advantage is that the environment is clean and repeatable — ideal for testing the idempotence of the Ansible playbook.

---
### 14.2 More information about deployment testing via Vagrant
Testing of the provisioning process was also carried out in a separate repository [vagrant-nginx-provisioning](https://github.com/Miska296/vagrant-nginx-provisioning), where minor adjustments to files and code were made for proper functioning in the Vagrant environment. This repository serves as an isolated testing environment that allows verifying the functionality of the playbook without affecting the main project `ansible-web-wm`.  

Provisioning was subsequently verified in GitHub Codespace after installing Ansible, confirming the compatibility of both environments.

---
## 15. Best practices
Recommendations for project management, service configuration, and maintaining a clean structure:

- Use `DEBIAN_FRONTEND=noninteractive` to suppress interactive prompts when installing packages.
- Use `ansible-vault` for the secure storage of sensitive information.
- After each provisioning, check the status of the services (`nginx`, `fail2ban`, `ssh`) and the open ports.
- Use `server_name _` in the NGINX configuration if you want the server to respond to requests from any domain or IP address. 
→ `server_name localhost` limits access to only the local machine, which may block access in environments like Codespaces or when testing from the outside.
- Add `listen [::]:80;` for IPv6 support, which increases availability in modern networks.
- After each configuration change in NGINX, run the provisioning again and check the status of the service.
- Document the project structure, deployment diagram, and provisioning outputs.
- Keep the repository structure clean — avoid nested folders.

---
## 16. Future improvements
- Adding automated testing using GitHub Actions
- Creating a dynamic web interface for provisioning
- Adding support for Docker-based deployment
- Implementing logging and monitoring (e.g. Prometheus, Grafana)
- Translation of the documentation into other languages
> This section serves as a roadmap for the further development of the project.

---
---
# Context and conclusion
## 17. Related project
This project is based on the original repository [static-web-test](https://github.com/Miska296/static-web-test), where a static web application was created using the Replit platform.
In the `ansible-web-wm` project, automation, security features, and extensive testing have been added.

---
## 18. Video presentation of the project
It shows the complete run of the script `provision.sh`, deployment of a web server using Ansible, and verification of functionality.

[![Presentation of the ansible-web-wm project](https://img.youtube.com/vi/aNvzjHr_p9I/0.jpg)](https://www.youtube.com/watch?v=aNvzjHr_p9I&t=3s)

---
## 19. Author
The project was prepared by [Michaela Kučerová](https://github.com/Miska296)  
**Version:** 1.0  
**Date:** July 2025  
**Last updated:** September 2025  
**Build:** OK

---
## 20. License
This project is available under the MIT license. Details see the file [LICENSE](LICENSE).
