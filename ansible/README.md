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
