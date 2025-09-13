# Ansible Proxmox Homelab

This repository contains Ansible playbooks to configure a Proxmox server.

## Usage

1.  Install Ansible and dependencies:
    ```bash
    pip install -r requirements.txt
    ansible-galaxy install -r roles/requirements.yml
    ```

2.  Secrets with Infisical (recommended)
    - Install CLI:
      ```bash
      brew install infisical/get-cli/infisical
      ```
    - Create a Service Token scoped to your project/environment/path (read-only).
    - Environment variable mapping used by group_vars (set these in Infisical):
      - `INFLUX_TOKEN`
      - `GMAIL_APP_PASSWORD`
      - `PBS_PASSWORD`
      - `PBS_FINGERPRINT`
      - `PVE_ADMIN_PASSWORD`
      - `ZT_NETWORK_ID`
      - `ZT_API_TOKEN`
      - `TS_AUTH_KEY` (optional; can be empty)
    - Run with env injection (no files written):
      ```bash
      INFISICAL_TOKEN=st.xxxxxx \
      infisical run --env=prod --path=/ansible -- \
      ansible-playbook -i inventory deploy.yml
      ```

3.  Update the `inventory` file and other vars to match your environment.

4.  Run the playbook:
    ```bash
    ansible-playbook -i inventory deploy.yml
    ```

## Secrets

This project uses environment-variable lookups for secrets and recommends Infisical to inject those env vars at runtime. No secrets are stored in the repo. If you prefer another injector, set the same environment variables before running Ansible.

# user mgmt
root + debian with pw, ssh pw login disabled. ansible will login via root ssh key.
ssh proxy router and set localhost in inventory:    ssh -J root@10.144.0.1 root@10.10.0.163
opt: change pw after login > todo make pw root debian comment
opt: create pve admin user, mfa all users
configure group_vars/pve01/vault.yml then encrypt it with SOPS

#troubleshoot
apt-get install --reinstall proxmox-widget-toolkit
