#!/bin/bash
set -eo pipefail

echo "Removing existing k3s installation (if any)..."
k3s-uninstall.sh || true

echo "Installing k3s..."
curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_START=true sh -

echo "Enabling and starting k3s using OpenRC..."
rc-service k3s start
rc-update add k3s default

echo "Checking k3s status..."
k3s kubectl get nodes

echo "Setting up kubectl..."
ln -sf /usr/local/bin/k3s /usr/local/bin/kubectl

echo "Reinstallation complete. Use 'k3s kubectl' or 'kubectl' to manage your cluster."
