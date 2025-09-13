#!/bin/bash

# Simplified macOS Testing Solution
# Uses direct cluster access and simplified networking

set -e

VM_NAME="tinkerbell-test"
VM_DISK="$VM_NAME.qcow2"
MAC_ADDR="00:11:22:33:44:55"

echo "=== Simplified macOS Tinkerbell Test ==="

# Get the actual cluster node IP
CLUSTER_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
echo "Cluster IP: $CLUSTER_IP"

# Get service NodePorts for direct access
HOOKOS_PORT=$(kubectl get svc hookos -n tinkerbell -o jsonpath='{.spec.ports[0].nodePort}')
TINK_DHCP_PORT=$(kubectl get svc tinkerbell -n tinkerbell -o jsonpath='{.spec.ports[?(@.name=="dhcp")].nodePort}')
TINK_TFTP_PORT=$(kubectl get svc tinkerbell -n tinkerbell -o jsonpath='{.spec.ports[?(@.name=="tftp")].nodePort}')

echo "Service ports:"
echo "  HookOS: $CLUSTER_IP:$HOOKOS_PORT"
echo "  DHCP: $CLUSTER_IP:$TINK_DHCP_PORT"
echo "  TFTP: $CLUSTER_IP:$TINK_TFTP_PORT"

# Create VM disk if needed
if [ ! -f "$VM_DISK" ]; then
    echo "Creating VM disk..."
    qemu-img create -f qcow2 "$VM_DISK" 20G
fi

# Test connectivity
echo "Testing connectivity to cluster services..."
if curl -s --connect-timeout 3 "http://$CLUSTER_IP:$HOOKOS_PORT" > /dev/null; then
    echo "✅ Can reach HookOS at $CLUSTER_IP:$HOOKOS_PORT"
else
    echo "❌ Cannot reach HookOS - checking with port forward..."
    kubectl port-forward -n tinkerbell svc/hookos 7173:7173 &
    PORT_FORWARD_PID=$!
    sleep 2
    if curl -s --connect-timeout 3 "http://localhost:7173" > /dev/null; then
        echo "✅ HookOS reachable via port-forward"
    fi
    kill $PORT_FORWARD_PID 2>/dev/null || true
fi

echo ""
echo "Starting VM with network boot..."
echo "VM will try PXE first, then disk boot"
echo "Monitor with: kubectl get workflows -n tinkerbell -w"

# Start VM with simplified networking
qemu-system-x86_64 \
    -name "$VM_NAME" \
    -m 2G \
    -smp 2 \
    -drive file="$VM_DISK",format=qcow2,if=virtio \
    -boot order=nc \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 \
    -device rtl8139,netdev=net0,mac="$MAC_ADDR" \
    -accel tcg \
    -display default \
    -monitor stdio