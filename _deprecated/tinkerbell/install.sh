#!/bin/bash

# Install Tinkerbell
helm upgrade -i tinkerbell -n tinkerbell oci://ghcr.io/tinkerbell/charts/tinkerbell --version v0.19.2 -f values.yaml --create-namespace

# Install ZeroTier Bridge
kubectl apply -f zerotier-bridge-daemonset.yaml

# Apply example configurations (optional - uncomment to use)
kubectl apply -f hardware.yaml -f template.yaml -f workflow.yaml -n tinkerbell
