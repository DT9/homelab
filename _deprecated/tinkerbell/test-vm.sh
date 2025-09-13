#!/bin/bash

# QEMU VM for testing Tinkerbell PXE boot
# Creates a VM that boots from network and can be provisioned by Tinkerbell

set -e

VM_NAME="tinkerbell-test"
VM_DISK="$VM_NAME.qcow2"
VM_MEMORY="2G"
VM_CPUS="2"
DISK_SIZE="20G"

# Network configuration - adjust to match your setup
BRIDGE_NAME="br0"
MAC_ADDR="00:11:22:33:44:55"  # Must match hardware.yaml

# Create disk if it doesn't exist
if [ ! -f "$VM_DISK" ]; then
    echo "Creating VM disk: $VM_DISK ($DISK_SIZE)"
    qemu-img create -f qcow2 "$VM_DISK" "$DISK_SIZE"
fi

# Check if we're on macOS or Linux for network setup
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - use user networking with port forwarding
    NETWORK_ARGS="-netdev user,id=net0,hostfwd=tcp::2222-:22 -device rtl8139,netdev=net0,mac=$MAC_ADDR"
    echo "Using macOS user networking (SSH will be available on port 2222)"
else
    # Linux - try to use bridge if available, fallback to user networking
    if ip link show "$BRIDGE_NAME" >/dev/null 2>&1; then
        NETWORK_ARGS="-netdev bridge,id=net0,br=$BRIDGE_NAME -device rtl8139,netdev=net0,mac=$MAC_ADDR"
        echo "Using bridge network: $BRIDGE_NAME"
    else
        NETWORK_ARGS="-netdev user,id=net0,hostfwd=tcp::2222-:22 -device rtl8139,netdev=net0,mac=$MAC_ADDR"
        echo "Bridge not found, using user networking (SSH will be available on port 2222)"
    fi
fi

echo "Starting VM: $VM_NAME"
echo "MAC Address: $MAC_ADDR"
echo "Memory: $VM_MEMORY"
echo "CPUs: $VM_CPUS"
echo ""
echo "VM will attempt PXE boot first, then boot from disk if available"
echo "Use Ctrl+Alt+G to release mouse, Ctrl+Alt+2 for QEMU monitor"
echo ""

# Start QEMU VM
exec qemu-system-x86_64 \
    -name "$VM_NAME" \
    -m "$VM_MEMORY" \
    -smp "$VM_CPUS" \
    -drive file="$VM_DISK",format=qcow2,if=virtio \
    -boot order=nc \
    $NETWORK_ARGS \
    -rtc base=utc \
    -accel tcg \
    -display default \
    -monitor stdio \
    "$@"