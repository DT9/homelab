#!/usr/bin/env bash
set -euo pipefail

# Resolve the directory of this script and mount that, not $PWD
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRESEED="$SCRIPT_DIR/preseed.cfg"

if [[ ! -f "$PRESEED" ]]; then
  echo "Error: preseed.cfg not found at $PRESEED"
  exit 1
fi

echo "Testing preseed.cfg syntax... ($PRESEED)"

# Avoid bind mounts entirely: stream preseed.cfg to container stdin
docker run --rm -i \
  debian:bookworm \
  bash -lc 'apt-get update -qq && apt-get install -y -qq debconf-utils && debconf-set-selections --checkonly /dev/stdin' \
  < "$PRESEED"

rc=$?
if [[ $rc -eq 0 ]]; then
  echo "✓ preseed.cfg syntax is valid"
else
  echo "✗ preseed.cfg has syntax errors"
fi
exit $rc
