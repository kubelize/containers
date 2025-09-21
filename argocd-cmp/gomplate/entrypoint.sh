#!/bin/bash

echo "🚀 Starting Gomplate ArgoCD CMP Plugin"

# Set default values for gomplate environment variables if not provided
export GOMPLATE_TIMEOUT=${GOMPLATE_TIMEOUT:-30s}
export GOMPLATE_LOG_LEVEL=${GOMPLATE_LOG_LEVEL:-info}

# Verify gomplate installation
if ! command -v gomplate &> /dev/null; then
    echo "❌ gomplate binary not found"
    exit 1
fi

echo "✅ gomplate version: $(gomplate --version)"

# Set up common data sources that might be used in templates
# These can be overridden by environment variables prefixed with GOMPLATE_

# Kubernetes-related environment setup
if [ -f "/var/run/secrets/kubernetes.io/serviceaccount/token" ]; then
    echo "🔐 Kubernetes service account detected"
    export GOMPLATE_K8S_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
    export GOMPLATE_K8S_NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace 2>/dev/null || echo "default")
fi

# ArgoCD-specific environment variables
echo "🔧 ArgoCD Environment Variables:"
env | grep -E "^ARGOCD_" | sort

# Additional data source setup for gomplate
# AWS credentials (if available)
if [ -n "$AWS_ACCESS_KEY_ID" ] && [ -n "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "☁️  AWS credentials detected"
fi

# Vault integration (if available)
if [ -n "$VAULT_ADDR" ] && [ -n "$VAULT_TOKEN" ]; then
    echo "🔒 Vault integration available"
fi

# Set up gomplate data sources environment
# These will be available as environment variables to gomplate templates
export GOMPLATE_DATASOURCE_ENV="env:///"

echo "🏁 Gomplate CMP Plugin ready"

# Execute the command passed by ArgoCD (typically the CMP server)
exec "$@"
