#!/bin/bash

echo "Testing preseed.cfg syntax..."
docker run --rm -v $(pwd):/workspace debian:bookworm bash -c "apt-get update -qq && apt-get install -y debconf-utils && debconf-set-selections -c /workspace/preseed.cfg"

if [ $? -eq 0 ]; then
    echo "✓ preseed.cfg syntax is valid"
else
    echo "✗ preseed.cfg has syntax errors"
    exit 1
fi