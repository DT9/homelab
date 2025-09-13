# Ansible Proxmox Homelab

This repository contains Ansible playbooks to configure a Proxmox server.

git remote set-url origin git@github-dt9:dt9/homelab.git

## Usage

1.  Install Ansible and dependencies (uv recommended):
    ```bash
    cd ansible
    uv sync
    ansible-galaxy collection install -r collections/requirements.yml
    ansible-galaxy install -r roles/requirements.yml
    ```
    If you are not using `uv`, run `pip install -r requirements.txt` instead.

2.  Configure Infisical secrets (using the `infisical.vault` collection)
    - Create a Machine Identity (universal auth) that can read your project secrets.
    - Populate the following environment variables before running Ansible:
      - `INFISICAL_CLIENT_ID` and `INFISICAL_CLIENT_SECRET` (machine identity credentials)
      - `INFISICAL_PROJECT_ID`
      - `INFISICAL_ENV_SLUG`
      - `INFISICAL_PATH`
      - `INFISICAL_API_URL` if you host Infisical yourself (defaults to the SaaS URL)
    - Store these Infisical secret keys under the path above so the lookup plugin can resolve them:
      - `INFLUX_TOKEN`
      - `GMAIL_APP_PASSWORD`
      - `PBS_PASSWORD`
      - `PBS_FINGERPRINT`
      - `PVE_ADMIN_PASSWORD`
      - `ZT_NETWORK_ID`
      - `ZT_API_TOKEN`
      - `TS_AUTH_KEY` (optional)

3.  Update the `inventory` file and other vars to match your environment.

4.  Run the playbook (or use `tests/run.sh` for the Infisical smoke test):
    ```bash
    dotenvx run -- env OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES uv run ansible-playbook -i inventory deploy.yml
    ```

## Secrets

Secrets are retrieved at runtime through the `infisical.vault.read_secrets` lookup. The lookup requires the `infisicalsdk` Python package (installed via `requirements.txt`) and the environment variables listed above. If you prefer to manage secrets differently, adjust `group_vars/pve01/vault.yml` accordingly or replace it with your own encrypted vars file.

# user mgmt
root + debian with pw, ssh pw login disabled. ansible will login via root ssh key.
ssh proxy router and set localhost in inventory:    ssh -J root@10.144.0.1 root@10.10.0.163
opt: change pw after login > todo make pw root debian comment
opt: create pve admin user, mfa all users
configure group_vars/pve01/vault.yml then encrypt it with SOPS

#troubleshoot
apt-get install --reinstall proxmox-widget-toolkit
