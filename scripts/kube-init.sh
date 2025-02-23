#!/bin/bash
set -eo pipefail

# Configuration paths
K3S_CONFIG_DIR="/etc/rancher/k3s"
K3S_CONFIG="${K3S_CONFIG_DIR}/k3s.yaml"

# Ensure configuration directory exists
mkdir -p "${K3S_CONFIG_DIR}"

# Enable and start k3s service
echo "Enabling and starting k3s..."
sudo systemctl enable k3s
sudo systemctl start k3s

# Wait for k3s to be ready
sleep 10

# Set up KUBECONFIG for k3s
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> ~/.bashrc

# Verify cluster access
if ! kubectl cluster-info --request-timeout=10s; then
  echo "Failed to connect to Kubernetes cluster"
  exit 1
fi

# Verify kubectl version
echo "Kubectl Version:"
kubectl version --client -o json | jq -r '.clientVersion.gitVersion'

echo "k3s initialization complete!"
