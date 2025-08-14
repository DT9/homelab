#!/bin/bash

# Install Ansible requirements
ansible-galaxy install -r roles/requirements.yml

# Run all Ansible playbooks
echo "Running site.yml..."
ansible-playbook -i inventory site.yml

echo "Running networking-vpn.yml..."
ansible-playbook -i inventory playbooks/networking-vpn.yml

echo "All playbooks completed!"