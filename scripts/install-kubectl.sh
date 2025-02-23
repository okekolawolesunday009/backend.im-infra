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

  # Download and install kubectl
  # Download K3s kubectl for ARM architecture
  curl -sfL https://get.k3s.io | sh -s - --arch arm64


  # After installation, K3s will install kubectl at /usr/local/bin/kubectl
  chmod +x kubectl
  mv kubectl /usr/local/bin/

  # Verify installation
  if ! command -v kubectl &> /dev/null; then
    echo "kubectl installation failed!"
    exit 1
  fi
  echo "kubectl installed successfully."
else
  echo "kubectl is already installed."
fi
