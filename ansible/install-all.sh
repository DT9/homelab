#!/bin/bash

# Install Ansible requirements
ansible-galaxy install -r roles/requirements.yml --force

# Run all Ansible playbooks
echo "Running deploy.yml..."
ansible-playbook -i inventory deploy.yml

echo "All playbooks completed!"