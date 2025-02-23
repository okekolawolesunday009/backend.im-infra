#!/bin/sh
set -eo pipefail

echo "Installing k3s without service manager..."
curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_START=true sh -

echo "Manually starting K3s..."
/usr/local/bin/k3s server --disable traefik --write-kubeconfig-mode 644 &

echo "Waiting for K3s to be ready..."
sleep 10  # Adjust if needed

echo "Setting up kubectl..."
ln -sf /usr/local/bin/k3s /usr/local/bin/kubectl

echo "K3s installation complete. Use 'kubectl get nodes' to verify."
