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
  curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
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

# Install K3s if not already installed
if ! command -v k3s &> /dev/null; then
  echo "K3s not found, installing it..."

  # Check if systemd or openrc is available
  if ! command -v systemctl &> /dev/null && ! command -v openrc &> /dev/null; then
    echo "Warning: systemd or openrc not found. K3s will be installed without service management."

    # Install K3s with no service management
    curl -sfL https://get.k3s.io | sh -s - --no-deploy servicelb
  else
    # Install K3s normally
    curl -sfL https://get.k3s.io | sh -
  fi

  echo "K3s installed successfully."
else
  echo "K3s is already installed."
fi
