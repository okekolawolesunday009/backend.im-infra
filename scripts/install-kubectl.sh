#!/bin/sh
set -eo pipefail

echo "Removing existing k3s installation (if any)..."
if [ -f "/usr/local/bin/k3s-uninstall.sh" ]; then
    /usr/local/bin/k3s-uninstall.sh || true
else
    echo "No previous k3s installation found, skipping uninstall."
fi

echo "Installing k3s..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --disable traefik" sh -

echo "Starting k3s manually (no systemd or openrc)..."
/usr/local/bin/k3s server --disable traefik &

echo "Waiting for k3s to initialize..."
sleep 10

echo "Checking k3s status..."
/usr/local/bin/k3s kubectl get nodes

echo "Setting up kubectl..."
ln -sf /usr/local/bin/k3s /usr/local/bin/kubectl

echo "Installation complete! Use 'k3s kubectl' or 'kubectl' to manage your cluster."
