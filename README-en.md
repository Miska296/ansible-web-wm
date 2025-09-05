# ansible-web-wm
Automated deployment and security configuration of a web server using Ansible

---
## Project Overview
This project automates the installation and configuration of a Linux-based web server using Ansible. It includes:
- Roles for NGINX, Fail2ban, firewall, SSH hardening, and automatic updates
- Use of `ansible-vault` for secure password storage
- Playbooks and a provisioning script for easy deployment

The project builds on [static-web-test](https://github.com/Miska296/static-web-test), originally created in Replit, and expands it with security features, automation, and system administration.

**Fully tested — provisioning completed successfully, all services verified.**

![Deployment Diagram](deployment-diagram.png)

---
## Key Features
- Secure configuration: firewall, Fail2ban, SSH restrictions
- Automatic system updates
- Dedicated user `webapp` with hashed password
- Static website deployment from GitHub
- Encrypted variables via `ansible-vault`

---
## Requirements
- Python 3.8+
- Ansible 2.10+
- Linux server or VM with SSH access
- Vault password for encrypted variables
- Properly configured `inventory/hosts.ini`
- `sudo` installed for privilege escalation

---
## How to Run
```bash
git clone https://github.com/Miska296/ansible-web-wm.git
cd ansible-web-wm
export ANSIBLE_ROLES_PATH="./roles"
./provision.sh
```
Enter your Vault password when prompted. Access the deployed site via http://localhost or your server IP.

---
## Security Highlights
- Passwords encrypted with ansible-vault
- SSH login hardened (no root, no password login)
- Firewall configured to allow only essential ports
- Fail2ban installed and active

---
## Project Structure
- inventory/hosts.ini
- playbooks/webserver.yml
- roles/ (users, webserver, firewall, ssh, updates)
- group_vars/web/vault (encrypted secrets)
- provision.sh
- README.md

## Troubleshooting
During provisioning, the script may pause due to interactive prompts from `apt`, especially when updating configuration files like `sshd_config`.
To prevent this, the script sets:
```bash
export DEBIAN_FRONTEND=noninteractive
```
This ensures non-interactive behavior during package installation and upgrades.
If provisioning hangs, press Ctrl + C, run sudo apt upgrade manually, and choose to keep the current configuration (option 2).

---
## Best Practices
- Always use `DEBIAN_FRONTEND=noninteractive` in automated scripts to avoid blocking prompts.
- Structure your roles and playbooks clearly for maintainability.
- Use `ansible-vault` for sensitive data.
- Validate provisioning with `failed=0` and service status checks.
- Document your project thoroughly — including diagrams, screenshots, and troubleshooting steps.

---
## Author
Created by Michaela Kučerová Version: 1.0 Date: July 2025

---
## License
This project is licensed under the MIT License. See [LICENSE](https://github.com/Miska296/ansible-web-wm/blob/main/LICENSE) for details.
