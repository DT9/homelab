#!/bin/bash

# Test monitor for macOS Tinkerbell testing
# Monitors workflow status and VM behavior

echo "=== Tinkerbell Test Monitor ==="

# Monitor workflow changes for 60 seconds
echo "Monitoring workflow status for 60 seconds..."
timeout 60s kubectl get workflows -n tinkerbell -w &
WATCH_PID=$!

# Monitor VM disk changes
VM_DISK="tinkerbell-test.qcow2"
if [ -f "$VM_DISK" ]; then
    INITIAL_SIZE=$(stat -f%z "$VM_DISK" 2>/dev/null || stat -c%s "$VM_DISK" 2>/dev/null)
    echo "Initial VM disk size: $INITIAL_SIZE bytes"
    
    # Check for disk size changes (indicates VM activity)
    for i in {1..12}; do
        sleep 5
        if [ -f "$VM_DISK" ]; then
            CURRENT_SIZE=$(stat -f%z "$VM_DISK" 2>/dev/null || stat -c%s "$VM_DISK" 2>/dev/null)
            if [ "$CURRENT_SIZE" != "$INITIAL_SIZE" ]; then
                echo "VM disk size changed: $CURRENT_SIZE bytes (VM is active)"
                INITIAL_SIZE=$CURRENT_SIZE
            fi
        fi
        echo "Check $i/12: VM disk monitoring..."
    done
fi

# Kill background processes
kill $WATCH_PID 2>/dev/null || true

# Final status check
echo ""
echo "=== Final Status ==="
kubectl get workflows -n tinkerbell
echo ""

# Check if any VM processes are running
if pgrep -f "qemu-system-x86_64.*tinkerbell" > /dev/null; then
    echo "✅ VM process is still running"
    echo "VM PIDs: $(pgrep -f 'qemu-system-x86_64.*tinkerbell')"
else
    echo "❌ No VM process found"
fi

# Check VM disk
if [ -f "$VM_DISK" ]; then
    FINAL_SIZE=$(stat -f%z "$VM_DISK" 2>/dev/null || stat -c%s "$VM_DISK" 2>/dev/null)
    echo "Final VM disk size: $FINAL_SIZE bytes"
    
    if [ "$FINAL_SIZE" -gt 500000 ]; then
        echo "✅ VM disk has significant content (likely bootable)"
    else
        echo "ℹ️  VM disk is still mostly empty"
    fi
fi