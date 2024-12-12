#!/usr/bin/env bash

source ~/helm.vars
# Default parameter value
TARGET=${1:-base}

# Directory to check for YAML files
CONFIG_DIR="/etc/genestack/helm-configs/grafana"

# Helm command setup
HELM_CMD="helm upgrade --install grafana grafana/grafana \
    --version 7.3.6 \
    --namespace=grafana \
    --create-namespace \
    --timeout 120m \
    --post-renderer /etc/genestack/kustomize/kustomize.sh \
    --post-renderer-args grafana/${TARGET} \
    -f /opt/genestack/base-helm-configs/grafana/overrides.yaml"

# Check if YAML files exist in the specified directory
if compgen -G "${CONFIG_DIR}/*.yaml" > /dev/null; then
    # Add all YAML files from the directory to the helm command
    for yaml_file in "${CONFIG_DIR}"/*.yaml; do
        HELM_CMD+=" -f ${yaml_file}"
    done
fi

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
# Run the helm command
echo "Executing Helm command:"
echo "${HELM_CMD}"
eval "${HELM_CMD}"
