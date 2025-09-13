#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

if [[ -z "${INFISICAL_CLIENT_ID:-}" || -z "${INFISICAL_CLIENT_SECRET:-}" ]] && \
   [[ -z "${INSTALL_ALL_DOTENVX:-}" ]] && \
   command -v dotenvx >/dev/null 2>&1 && \
   [[ -f "${SCRIPT_DIR}/.env" ]]; then
  export INSTALL_ALL_DOTENVX=1
  exec dotenvx run -- "$0" "$@"
fi

mkdir -p .ansible/tmp .ansible/cp roles collections

if ! command -v uv >/dev/null 2>&1; then
  echo "uv is required but not installed. Install it (e.g. curl -LsSf https://astral.sh/uv/install.sh | sh)." >&2
  exit 1
fi

# Ensure the uv-managed virtual environment exists (skip by setting SKIP_UV_SYNC=1).
if [[ -z "${SKIP_UV_SYNC:-}" ]]; then
  uv sync
fi

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
