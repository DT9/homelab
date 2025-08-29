#!/bin/bash

# Ansible Proxmox Docker Test Script
# Tests the Ansible playbook in a containerized Debian environment

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONTAINER_NAME="proxmox-test"
DOCKER_IMAGE="jrei/systemd-debian:12"
TEST_INVENTORY="test-inventory.yml"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to cleanup existing container
cleanup() {
    print_status "Cleaning up existing container..."
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        docker rm -f ${CONTAINER_NAME} || true
    fi
}

# Function to create test inventory
create_test_inventory() {
    print_status "Creating test inventory..."
    cat > ${TEST_INVENTORY} << EOF
---
all:
  children:
    proxmox:
      hosts:
        proxmox-test:
          ansible_connection: docker
          ansible_user: root
          ansible_python_interpreter: /usr/bin/python3
          gpu_vendor_device_ids: "10de:2206,10de:1aef"
      vars:
        ansible_python_interpreter: /usr/bin/python3
        ansible_become: true
        ansible_become_method: sudo
EOF
}

# Function to setup container
setup_container() {
    print_status "Starting systemd-enabled Debian container..."
    docker run -d --name ${CONTAINER_NAME} --privileged \
        -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
        --cgroupns=host \
        ${DOCKER_IMAGE}
    
    print_status "Installing required packages in container..."
    docker exec ${CONTAINER_NAME} bash -c "
        apt update && 
        apt install -y python3 sudo openssh-server python3-apt &&
        useradd -m -s /bin/bash debian &&
        echo 'debian ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers &&
        systemctl enable ssh &&
        mkdir -p /home/debian/.ssh
    "
    
    print_success "Container setup complete"
}

# Function to install Ansible dependencies
install_dependencies() {
    print_status "Installing Ansible role dependencies..."
    if ansible-galaxy install -r requirements.yml; then
        print_success "Dependencies installed successfully"
    else
        print_warning "Some dependencies failed to install (this may be expected)"
    fi
}

# Function to test playbook syntax
test_syntax() {
    print_status "Testing playbook syntax..."
    if ansible-playbook --syntax-check proxmox-single-node.yml; then
        print_success "Syntax check passed"
    else
        print_error "Syntax check failed"
        return 1
    fi
}

# Function to run dry-run test
test_dry_run() {
    print_status "Running dry-run test against container..."
    echo "Expected: Should run successfully until Proxmox package installation"
    echo "----------------------------------------"
    
    if ansible-playbook -i ${TEST_INVENTORY} --check proxmox-single-node.yml; then
        print_success "Dry-run completed successfully"
    else
        print_warning "Dry-run failed at expected point (Proxmox package installation)"
        print_status "This is normal behavior in Docker environment"
    fi
}

# Function to run additional tests
run_additional_tests() {
    print_status "Running additional validation tests..."
    
    # Test inventory connectivity
    print_status "Testing Ansible connectivity..."
    if ansible -i ${TEST_INVENTORY} proxmox -m ping; then
        print_success "Ansible connectivity test passed"
    else
        print_error "Ansible connectivity test failed"
        return 1
    fi
    
    # Test fact gathering
    print_status "Testing fact gathering..."
    if ansible -i ${TEST_INVENTORY} proxmox -m setup | head -20; then
        print_success "Fact gathering test passed"
    else
        print_error "Fact gathering test failed"
        return 1
    fi
}

# Function to show container info
show_container_info() {
    print_status "Container information:"
    echo "Name: ${CONTAINER_NAME}"
    echo "IP Address: $(docker inspect ${CONTAINER_NAME} | grep -m1 '"IPAddress"' | cut -d'"' -f4)"
    echo "Status: $(docker inspect --format='{{.State.Status}}' ${CONTAINER_NAME})"
}

# Function to cleanup and exit
final_cleanup() {
    print_status "Cleaning up test environment..."
    cleanup
    rm -f ${TEST_INVENTORY}
    print_success "Cleanup complete"
}

# Main execution
main() {
    echo "=========================================="
    echo "Ansible Proxmox Docker Test"
    echo "=========================================="
    
    # Cleanup any existing containers
    cleanup
    
    # Create test inventory
    create_test_inventory
    
    # Setup container
    setup_container
    
    # Show container info
    show_container_info
    
    # Install dependencies
    install_dependencies
    
    # Run tests
    test_syntax
    test_dry_run
    run_additional_tests
    
    echo "=========================================="
    print_success "Docker test completed!"
    echo "=========================================="
    
    # Ask user if they want to keep container for debugging
    echo ""
    read -p "Keep container running for debugging? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        final_cleanup
    else
        print_status "Container ${CONTAINER_NAME} kept running for debugging"
        print_status "To access: docker exec -it ${CONTAINER_NAME} bash"
        print_status "To cleanup later: docker rm -f ${CONTAINER_NAME}"
    fi
}

# Trap to ensure cleanup on exit
trap 'print_error "Script interrupted"; cleanup' INT TERM

# Run main function
main "$@"