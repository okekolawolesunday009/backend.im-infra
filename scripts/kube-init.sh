#!/bin/bash
set -eo pipefail

# Determine configuration mode
KUBECONFIG_MODE=${KUBECONFIG_MODE:-aws}

if [ "$KUBECONFIG_MODE" = "manual" ]; then
    echo "Using manual Kubernetes configuration mode..."
    
    # Verify mounted config exists
    if [ ! -f "$HOME/.kube/config" ]; then
        echo "ERROR: Must set KUBECONFIG_FILE in manual mode" >&2
        exit 1
    fi
    
    echo "Using mounted kubeconfig from ${KUBECONFIG_FILE}"
    
elif [ "$KUBECONFIG_MODE" = "aws" ]; then
    echo "Using AWS EKS configuration mode..."
    
    # Validate required AWS variables
    required_vars=(AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION KUBE_CLUSTER_NAME)
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            echo "ERROR: Missing required environment variable $var" >&2
            exit 1
        fi
    done
    
    # Remove any existing config to ensure clean state
    if [ -f "$HOME/.kube/config" ]; then
        echo "Warning: Removing existing kubeconfig for clean AWS setup"
        rm "$HOME/.kube/config"
    fi
    
    # Configure AWS CLI
    aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
    aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
    aws configure set default.region ${AWS_DEFAULT_REGION}

    # Verify EKS cluster exists
    if ! aws eks describe-cluster --name ${KUBE_CLUSTER_NAME} >/dev/null; then
        echo "ERROR: Failed to access EKS cluster '${KUBE_CLUSTER_NAME}'" >&2
        exit 1
    fi

    # Generate kubeconfig with strict validation
    aws eks update-kubeconfig \
        --name ${KUBE_CLUSTER_NAME} \
        --region ${AWS_DEFAULT_REGION} \
        --kubeconfig ${KUBECONFIG} \
        --alias automated-cluster
    
    # Verify AWS credentials
    echo "AWS Identity:"
    aws sts get-caller-identity
else
    echo "ERROR: Invalid KUBECONFIG_MODE '${KUBECONFIG_MODE}'" >&2
    echo "Must be either 'aws' or 'manual'" >&2
    exit 1
fi

# Verify cluster access with timeout
if ! kubectl cluster-info --request-timeout=10s; then
    echo "Failed to connect to Kubernetes cluster" >&2
    exit 1
fi

# Verify kubectl version
echo "Kubectl Version:"
kubectl version --client -o json | jq -r '.clientVersion.gitVersion'

# Execute the passed command
exec "$@"
