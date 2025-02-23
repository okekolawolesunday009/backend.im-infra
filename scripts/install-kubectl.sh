#!/bin/sh
set -eo pipefail

# Ensure the script runs as root
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

echo "Installing kubectl..."

# Install kubectl (if not installed)
if ! command -v kubectl &> /dev/null; then
  echo "kubectl not found, installing it..."

  # Download and install kubectl for K3s
  curl -sfL https://get.k3s.io | sh -s - --arch arm64
  
  # Check if the download was successful
  if [ $? -ne 0 ]; then
    echo "Failed to install K3s. Exiting..."
    exit 1
  fi

  # Verify kubectl is installed by checking its location
  if [ ! -f /usr/local/bin/kubectl ]; then
    echo "kubectl installation failed!"
    exit 1
  fi

  chmod +x /usr/local/bin/kubectl

  # Verify kubectl installation
  if ! command -v kubectl &> /dev/null; then
    echo "kubectl installation failed!"
    exit 1
  fi

  echo "kubectl installed successfully."
else
  echo "kubectl is already installed."
fi

# Final check
kubectl version --client || { echo "kubectl check failed."; exit 1; }

echo "K3s and kubectl setup complete."
