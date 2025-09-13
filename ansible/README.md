# Ansible Proxmox Homelab

This repository contains Ansible playbooks to configure a Proxmox server.

## Usage

1.  Install Ansible and dependencies:
    ```bash
    pip install -r requirements.txt
    ansible-galaxy install -r roles/requirements.yml
    ```

2.  Create a `.env` file with the following content:
    ```
    VAULT_PASSWORD=your_secret_password
    ```

3.  Update the `inventory` file with your Proxmox server details.

4.  Update the variables in `group_vars` to match your environment.

5.  Encrypt the `group_vars/pve01/vault.yml` file with the vault password:
    ```bash
    source .env && ansible-vault encrypt group_vars/pve01/vault.yml --vault-password-file <(echo "$VAULT_PASSWORD")
    ```

6.  Run the playbook:
    ```bash
    source .env && ansible-playbook -i inventory deploy.yml --vault-password-file <(echo "$VAULT_PASSWORD")
    ```

## Vault

This project uses Ansible Vault to store sensitive data. The vault password is read from the `.env` file.

# user mgmt
root + debian with pw, ssh pw login disabled. ansible will login via root ssh key.
ssh proxy router and set localhost in inventory:    ssh -J root@10.144.0.1 root@10.10.0.163
opt: change pw after login > todo make pw root debian comment
opt: create pve admin user, mfa all users
configure groups_vars/pve01/vault.yml

#troubleshoot
apt-get install --reinstall proxmox-widget-toolkit
