#!/bin/sh
set -eo pipefail

# echo "Removing existing k3s installation (if any)..."
# if [ -f "/usr/local/bin/k3s-uninstall.sh" ]; then
#     /usr/local/bin/k3s-uninstall.sh || true
# else
#     echo "No previous k3s installation found, skipping uninstall."
# fi

echo "Installing k3s..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --disable traefik" sh -

echo "Installing K3s without service manager..."
curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_ENABLE=true sh -

echo "Checking K3s status..."
k3s kubectl get nodes

echo "Setting up kubectl..."
ln -sf /usr/local/bin/k3s /usr/local/bin/kubectl

echo "Installation complete. Use 'k3s kubectl' or 'kubectl' to manage your cluster."
