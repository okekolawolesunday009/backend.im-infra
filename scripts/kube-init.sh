#!/bin/bash
set -eo pipefail

echo "Configuring K3s..."

# Define K3S directory and file
K3S_CONFIG_DIR="/etc/rancher/k3s"
K3S_CONFIG="${K3S_CONFIG_DIR}/k3s.yaml"

# Create the directory with appropriate permissions
if [ ! -d "$K3S_CONFIG_DIR" ]; then
    echo "Creating $K3S_CONFIG_DIR"
    sudo mkdir -p "${K3S_CONFIG_DIR}"
    sudo chown -R backenduser:backenduser "${K3S_CONFIG_DIR}"
fi

sleep 10

# Set up KUBECONFIG
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" | sudo tee -a /etc/profile.d/k3s.sh

# Ensure kubectl is accessible
export PATH=$PATH:/usr/local/bin

# Verify cluster access
if ! kubectl cluster-info --request-timeout=10s; then
  echo "Failed to connect to Kubernetes cluster."
  exit 1
fi

# Display Kubectl version
echo "Kubectl Version:"
kubectl version --client -o json | jq -r '.clientVersion.gitVersion'

echo "K3s initialization complete!"
