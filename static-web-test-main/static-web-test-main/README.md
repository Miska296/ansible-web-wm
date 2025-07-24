# Projekt: Ansible Web Server Setup
Tento projekt automatizuje konfiguraci Linuxového serveru (Ubuntu 22.04) pomocí Ansible. Cílem je vytvořit jednoduchou webovou službu (NGINX) a nastavit ji bezpečně pro provoz.

## Cíle
- Vytvořit Ansible projekt podle best practices
- Nasadit webový server (NGINX) s vlastní konfigurací
- Nasadit HTML stránku z Git repozitáře nebo alternativně pomocí šablony
- Zajistit idempotentní chování a vlastnictví souborů
- Provoz služby na portu 80 s vlastní složkou pro obsah
- Zajistit bezpečné provozní nastavení

## Struktura projektu
- inventory/hosts.ini 
- group_vars/web.yml
- group_vars/web_secrets.yml (simulace citlivých dat)
- playbooks/webserver.yml
- roles/users/tasks/main.yml
- roles/webserver/tasks/main.yml
- roles/webserver/handlers/main.yml
- roles/webserver/templates/index.html.j2 (zakomentován - Git nahrazuje)
- roles/webserver/templates/nginx.conf.j2
- roles/webserver/vars/main.yml
- roles/firewall/tasks/main.yml
- roles/ssh/tasks/main.yml
- roles/ssh/handlers/main.yml
- roles/updates/tasks/main.yml
- roles/updates/handlers/main.yml
- README.md

## Spuštění projektu
```bash
ansible-playbook -i inventory/hosts.ini playbooks/webserver.yml
```

## Webový obsah z GitHubu
- Webová stránka index.html je stažena z veřejného GitHub repozitáře: `https://github.com/Miska296/static-web-test`
- Stažení probíhá pomocí modulu `git` v roli `webserver`
- Obsah je automaticky umístěn do složky /opt/static-sites
- Vlastnictví složky je nastaveno na uživatele webapp
- Lokální šablona `index.html.j2` byla zakomentována a nahrazena reálným obsahem

## Nasazení služby
- NGINX používá vlastní konfiguraci ze souboru nginx.conf.j2
- Web běží na portu 80
- Konfigurace a soubory jsou idempotentně kontrolovány
- Restart služby probíhá pouze při změně
- Vlastník obsahu je uživatel `webapp` (automaticky vytvořen)

## Idempotence
- Instalace balíčků přes apt jen pokud chybí
- Konfigurační soubory přes template s notifikací
- Restart služeb jen při změně (handlers)
- Proměnné jsou definovány v `group_vars/` a `vars/` pro přehlednost
- Modul file pro kontrolu vlastnictví, práv a adresářové struktury

## Firewall (UFW)
- Instalace nástroje `ufw`
- Povolení portů 22 (SSH) a 80 (HTTP)
- Zablokování ostatních příchozích spojení
- Aktivace firewallu pomocí role firewall
- Modul `community.general.ufw` je součástí kolekce `community.general`. Instalace na reálném serveru:
```bash
ansible-galaxy collection install community.general
```

## Uživatel a oprávnění
- Vytvořen dedikovaný uživatel `webapp`
- Webové soubory v `/opt/static-sites` jsou jeho vlastnictvím
- NGINX procesy běží pod tímto uživatelem (`user webapp;` v `nginx.conf.j2`)
- Splněn požadavek na bezpečné provozní nastavení služby

## Zabezpečení SSH
- Přihlášení jako `root` bylo zakázáno (`PermitRootLogin no`)
- Přihlášení pomocí hesla bylo deaktivováno (`PasswordAuthentication no`)
- SSH přístup je možný **pouze pomocí SSH klíče**
- Konfigurace provedena pomocí role `ssh`
- Změny v `sshd_config` automaticky spouští restart služby

## Aktualizace a ochrana
- Automatické bezpečnostní aktualizace pomocí `unattended-upgrades`
- Konfigurace přes soubor `20auto-upgrades`
- Nainstalován a spuštěn `fail2ban` pro ochranu proti brute-force útokům
- Služba `fail2ban` chrání SSH přístup

## Validace funkčnosti
- Na konci playbooku je proveden HTTP test pomocí modulu `uri`
- Ověřuje se, že server odpovídá s kódem `200 OK`
- Kontroluje se, že odpověď obsahuje očekávaný text (např. „Hello from GitHub!“)
- V případě chyby se playbook ukončí s hlášením

## Citlivé proměnné s Ansible Vault (simulace)
- Projekt umožňuje bezpečné uchování citlivých hodnot pomocí `ansible-vault`.
Příklady dat:
- SSH klíče (`ssh_private_key`)
- Hesla (`db_password`, `api_token`)
Vytvoření šifrovaného souboru (simulace):
```bash
ansible-vault create group_vars/web_secrets.yml
```
V Replitu se složka /opt/static-sites nevytváří automaticky — Ansible ji vytvoří při reálném nasazení.

## Bonusové body
- Simulované uložení citlivých dat pomocí `ansible-vault` v šifrovaném souboru `web_secrets.yml`
- Webový obsah stažen z GitHub repozitáře pomocí modulu `git`
- Projekt využívá bezpečnostní prvky, automatizaci i monitoring

## Testování a doporučení
Projekt testován lokálně v Replitu:
- Ověřena syntaxe playbooku
- Načtení inventáře a proměnných
- Validace pomocí HTTP testu
Pro reálné nasazení doporučuji Linux VM s Ubuntu 22.04 (např. Hetzner, Oracle Cloud, VirtualBox).

## Autor
Projekt připravila: Michaela Kučerová 
Verze: 1.0 
Datum: červenec 2025