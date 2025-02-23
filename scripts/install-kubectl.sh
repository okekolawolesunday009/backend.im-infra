#!/bin/bash
set -eo pipefail

echo "Removing existing k3s installation (if any)..."
sudo k3s-uninstall.sh || true

echo "Installing k3s..."
curl -sfL https://get.k3s.io | sh -

echo "Enabling and starting k3s..."
sudo systemctl enable k3s
sudo systemctl start k3s

echo "Checking k3s status..."
k3s kubectl get nodes

echo "Setting up kubectl..."
sudo ln -sf /usr/local/bin/k3s /usr/local/bin/kubectl

echo "Reinstallation complete. Use 'k3s kubectl' or 'kubectl' to manage your cluster."
