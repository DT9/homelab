#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

mkdir -p .ansible/tmp .ansible/cp roles collections

uv sync

export ANSIBLE_CONFIG="${SCRIPT_DIR}/ansible.cfg"
export ANSIBLE_LOCAL_TEMP="${SCRIPT_DIR}/.ansible/tmp"
export ANSIBLE_ROLES_PATH="${SCRIPT_DIR}/roles"
export ANSIBLE_COLLECTIONS_PATH="${SCRIPT_DIR}/collections"

uv run ansible-galaxy collection install -p "${ANSIBLE_COLLECTIONS_PATH}" -r collections/requirements.yml
uv run ansible-galaxy install -p "${ANSIBLE_ROLES_PATH}" -r roles/requirements.yml

PLAYBOOKS=(deploy.yml playbooks/networking-vpn.yml)
if [[ -n "${INSTALL_ALL_PLAYBOOKS:-}" ]]; then
  PLAYBOOKS=(${INSTALL_ALL_PLAYBOOKS})
fi

if [[ $# -gt 0 ]]; then
  PLAYBOOKS=("$1")
  shift
fi

for playbook in "${PLAYBOOKS[@]}"; do
  dotenvx run -f ".env" -- env OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES uv run ansible-playbook -i inventory "${playbook}" "$@"
done
