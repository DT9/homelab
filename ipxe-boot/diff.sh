#!/bin/sh
# /root/config-diff-full.sh
# Tracks UCI, IP addresses, and DSA bridge state with automatic diff against previous snapshot

# opkg update
opkg install diffutils usbutils

SNAP_DIR="/root/config-snapshots"
mkdir -p "$SNAP_DIR"

# Find the most recent snapshot
PREV=$(ls -1t "$SNAP_DIR" | head -n 1)
STAMP=$(date +%Y%m%d_%H%M%S)
OUT="$SNAP_DIR/$STAMP"

mkdir -p "$OUT"

# Dump configs
uci show > "$OUT/uci.txt"
ip addr show > "$OUT/ip.txt"
bridge link > "$OUT/bridge_link.txt"
bridge vlan > "$OUT/bridge_vlan.txt"

echo "Snapshot saved to $OUT"

# Diff against previous snapshot if exists
if [ -n "$PREV" ] && [ "$PREV" != "$(basename $OUT)" ]; then
    echo
    echo "=== Differences from previous snapshot ($PREV) ==="
    echo "--- UCI changes ---"
    diff -u "$SNAP_DIR/$PREV/uci.txt" "$OUT/uci.txt"
    echo
    echo "--- IP changes ---"
    diff -u "$SNAP_DIR/$PREV/ip.txt" "$OUT/ip.txt"
    echo
    echo "--- Bridge link changes ---"
    diff -u "$SNAP_DIR/$PREV/bridge_link.txt" "$OUT/bridge_link.txt"
    echo
    echo "--- Bridge VLAN changes ---"
    diff -u "$SNAP_DIR/$PREV/bridge_vlan.txt" "$OUT/bridge_vlan.txt"
else
    echo "No previous snapshot to compare."
fi
