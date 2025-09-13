#!/bin/bash
set -euo pipefail

# Ensure Ansible uses a writable local temp within the repo (sandbox-safe)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export ANSIBLE_LOCAL_TEMP="${SCRIPT_DIR}/.ansible/tmp"
mkdir -p "${ANSIBLE_LOCAL_TEMP}"

# Log file for playbook output
LOG_FILE="${SCRIPT_DIR}/log.txt"
# Truncate existing log
: > "${LOG_FILE}"

# Install Ansible requirements (collections and roles)
ansible-galaxy collection install -r roles/requirements.yml
ansible-galaxy install -r roles/requirements.yml

# Run all Ansible playbooks
echo "Running deploy.yml... (logging to ${LOG_FILE})"
ansible-playbook -i inventory deploy.yml 2>&1 | tee "${LOG_FILE}"

echo "All playbooks completed!"
