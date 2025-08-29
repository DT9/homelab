#!/bin/bash

# VM Manager for Tinkerbell testing
# Provides easy commands to start, stop, reset VMs for testing

VM_NAME="tinkerbell-test"
VM_DISK="$VM_NAME.qcow2"
PID_FILE="/tmp/$VM_NAME.pid"

usage() {
    echo "Usage: $0 [start|stop|reset|status|console|ssh]"
    echo ""
    echo "Commands:"
    echo "  start   - Start the test VM (PXE boot enabled)"
    echo "  stop    - Stop the running VM"
    echo "  reset   - Delete VM disk and restart fresh"
    echo "  status  - Show VM status"
    echo "  console - Connect to VM console (if running)"
    echo "  ssh     - SSH to VM (port 2222 if using user networking)"
    echo ""
    echo "VM Configuration:"
    echo "  Name: $VM_NAME"
    echo "  Disk: $VM_DISK"
    echo "  MAC:  00:11:22:33:44:55"
}

start_vm() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "VM is already running (PID: $(cat $PID_FILE))"
        return 1
    fi
    
    echo "Starting VM for PXE boot testing..."
    ./test-vm.sh &
    echo $! > "$PID_FILE"
    echo "VM started (PID: $(cat $PID_FILE))"
}

stop_vm() {
    if [ ! -f "$PID_FILE" ]; then
        echo "VM is not running (no PID file)"
        return 1
    fi
    
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        echo "Stopping VM (PID: $PID)"
        kill "$PID"
        rm -f "$PID_FILE"
        echo "VM stopped"
    else
        echo "VM is not running (stale PID file)"
        rm -f "$PID_FILE"
    fi
}

reset_vm() {
    echo "Resetting VM - this will delete all data!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        stop_vm
        if [ -f "$VM_DISK" ]; then
            echo "Deleting VM disk: $VM_DISK"
            rm -f "$VM_DISK"
        fi
        echo "VM reset complete. Run 'start' to create fresh VM."
    else
        echo "Reset cancelled"
    fi
}

vm_status() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "VM is running (PID: $(cat $PID_FILE))"
        if [ -f "$VM_DISK" ]; then
            SIZE=$(du -h "$VM_DISK" | cut -f1)
            echo "Disk: $VM_DISK ($SIZE)"
        fi
    else
        echo "VM is not running"
        if [ -f "$VM_DISK" ]; then
            SIZE=$(du -h "$VM_DISK" | cut -f1)
            echo "Disk exists: $VM_DISK ($SIZE)"
        else
            echo "No VM disk found"
        fi
    fi
}

connect_ssh() {
    echo "Connecting to VM via SSH (port 2222)..."
    echo "Default users: root (no password) or admin (no password)"
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2222 admin@localhost
}

case "${1:-}" in
    start)
        start_vm
        ;;
    stop)
        stop_vm
        ;;
    reset)
        reset_vm
        ;;
    status)
        vm_status
        ;;
    ssh)
        connect_ssh
        ;;
    *)
        usage
        exit 1
        ;;
esac