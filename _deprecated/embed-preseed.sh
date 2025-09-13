#!/bin/bash
# embed-preseed.sh
# Usage: ./embed-preseed.sh initrd.gz preseed.cfg output-initrd.gz

set -e

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <initrd.gz> <preseed.cfg> <output-initrd.gz>"
    exit 1
fi

INITRD="$1"
PRESEED="$2"
OUTPUT="$3"

WORKDIR=$(mktemp -d)
echo "[*] Working in $WORKDIR"

# unpack initrd
echo "[*] Unpacking $INITRD ..."
gzip -dc "$INITRD" | (cd "$WORKDIR" && cpio -id --quiet)

# copy preseed.cfg
echo "[*] Embedding $PRESEED ..."
cp "$PRESEED" "$WORKDIR/preseed.cfg"

# repack initrd
echo "[*] Repacking to $OUTPUT ..."
cd "$WORKDIR"
find . | cpio -H newc -o --quiet | gzip -9 > "$OUTPUT"

echo "[*] Done! Output: $OUTPUT"

# cleanup
rm -rf "$WORKDIR"
