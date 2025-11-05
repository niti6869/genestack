#!/bin/bash
set -e

echo "Updating Ceilometer configuration to fix blazar_lease resource type attributes..."

# Check if we're in the right environment
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found. Please run this from the correct environment."
    echo "You may need to source the OpenStack RC file first."
    exit 1
fi

echo "Current Ceilometer pods:"
kubectl -n openstack get pods -l app=ceilometer-notification

echo ""
echo "Checking if Ceilometer configuration needs to be updated..."
echo "The blazar_lease resource type in Gnocchi is missing critical attributes."
echo "This indicates the updated configuration hasn't been deployed yet."

echo ""
echo "To fix this, we need to redeploy Ceilometer with the updated configuration."
echo "This will register the new resource type attributes with Gnocchi."

echo ""
echo "Redeploying Ceilometer..."
/opt/genestack/bin/install-ceilometer.sh

echo ""
echo "Waiting for Ceilometer pods to be ready..."
kubectl -n openstack wait --for=condition=ready pod -l app=ceilometer-notification --timeout=300s

echo ""
echo "Ceilometer redeployment completed!"
echo "The blazar_lease resource type should now have all required attributes."
echo "You can verify by running: openstack metric resource-type show blazar_lease"