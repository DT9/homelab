#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${ROOT_DIR}"

if ! command -v dotenvx >/dev/null 2>&1; then
  echo "dotenvx is required but not installed. Install it (e.g. brew install dotenvx)." >&2
  exit 1
fi

if ! command -v uv >/dev/null 2>&1; then
  echo "uv is required but not installed. Install it (e.g. curl -LsSf https://astral.sh/uv/install.sh | sh)." >&2
  exit 1
fi

if [[ -z "${SKIP_UV_SYNC:-}" ]]; then
  uv sync
fi

if [[ -z "${SKIP_GALAXY_INSTALL:-}" ]]; then
  uv run ansible-galaxy collection install -p "collections" -r collections/requirements.yml >/dev/null
  if [[ -f roles/requirements.yml ]]; then
    uv run ansible-galaxy install -p "roles" -r roles/requirements.yml >/dev/null
  fi
fi

required_vars=(
  INFISICAL_PROJECT_ID
  INFISICAL_ENV_SLUG
  INFISICAL_PATH
)

for var in "${required_vars[@]}"; do
  if ! dotenvx get -f ".env" "${var}" >/dev/null 2>&1; then
    echo "Missing ${var} in ${ROOT_DIR}/.env (or encrypted variant)." >&2
    exit 1
  fi
done

mkdir -p collections roles
export ANSIBLE_CONFIG="${ROOT_DIR}/ansible.cfg"
export ANSIBLE_COLLECTIONS_PATH="${ROOT_DIR}/collections${ANSIBLE_COLLECTIONS_PATH:+:${ANSIBLE_COLLECTIONS_PATH}}"
export ANSIBLE_COLLECTIONS_PATHS="${ROOT_DIR}/collections${ANSIBLE_COLLECTIONS_PATHS:+:${ANSIBLE_COLLECTIONS_PATHS}}"
export ANSIBLE_ROLES_PATH="${ROOT_DIR}/roles${ANSIBLE_ROLES_PATH:+:${ANSIBLE_ROLES_PATH}}"

dotenvx run -f ".env" -- \
  env OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES \
  uv run ansible-playbook tests/infisical.yml "$@"
