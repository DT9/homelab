# Repository Guidelines

## Project Structure & Module Organization
- ansible: Playbooks, inventory, group_vars, roles, templates, tests.
- ipxe-boot: iPXE scripts and Debian preseed assets.
- k8s: Kubernetes manifests (e.g., `zerotier-bridge-daemonset.yaml`).
- deprecated: Archived experiments and POCs.
- Top-level helpers: `erase-repo-history.sh`, `README.md`, `techstack.yml`.

## Build, Test, and Development Commands
- Ansible: `ansible-galaxy install -r ansible/roles/requirements.yml`
- Run deploy: `source ansible/.env && ansible-playbook -i ansible/inventory ansible/deploy.yml --vault-password-file <(echo "$VAULT_PASSWORD")`
- Dry-run: add `--check --diff` to any `ansible-playbook` command.
- Lint Ansible (optional): `ansible-lint ansible/`
- Test iPXE/preseed: `bash ipxe-boot/test-preseed.sh` and `bash ipxe-boot/diff.sh`
- Apply K8s: `kubectl apply -f k8s/zerotier-bridge-daemonset.yaml -n <namespace>`

## Coding Style & Naming Conventions
- YAML: 2-space indent; `.yml` extension; Ansible vars `snake_case`.
- Ansible: group/host vars under `ansible/group_vars/<group|host>/`; playbooks in `ansible/playbooks/`; keep roles minimal and idempotent.
- Shell: `#!/usr/bin/env bash` + `set -euo pipefail`; prefer long flags; validate with `shellcheck`.
- iPXE: keep host files `MAC-xx-xx-xx-xx-xx-xx.ipxe`.
- K8s: one resource per file when feasible; names `kebab-case`.

## Testing Guidelines
- Ansible: use `--check --diff`; target safely with `--limit <host|group>`.
- Local test files live in `ansible/test/` (e.g., `test-inventory.yml`). Example: `ansible-playbook -i ansible/test/test-inventory.yml ansible/test/vpn-setup-test.yml --check`.
- Shell: add simple `set -x` and temp dirs during tests; run `shellcheck`.
- K8s: apply to a non-prod namespace first; `kubectl -n <ns> describe/get logs` for verification.

## Commit & Pull Request Guidelines
- Commits: short, imperative subject. Prefix scope when useful (e.g., `ansible:`, `ipxe-boot:`, `k8s:`). Include rationale in body.
- PRs: clear description, affected paths, runbook (exact commands to validate), and any logs/screenshots. Link issues when applicable.

## Security & Configuration Tips
- Store secrets in `ansible/group_vars/.../vault.yml`; encrypt via `ansible-vault` using `VAULT_PASSWORD` from `ansible/.env`.
- Do not commit real secrets or host-specific credentials. Redact IPs and tokens in PRs.
