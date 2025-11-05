#!/bin/bash
set -e

echo "Redeploying Ceilometer to fix blazar_lease resource type registration..."

# First, let's delete the existing Ceilometer deployment to force a fresh deployment
echo "Deleting existing Ceilometer deployment..."
kubectl -n openstack delete deployment ceilometer-notification || true

# Wait a moment for the deployment to be fully deleted
echo "Waiting for deployment to be deleted..."
sleep 10

# Now redeploy Ceilometer with the updated configuration
echo "Redeploying Ceilometer with updated configuration..."
/opt/genestack/bin/install-ceilometer.sh

echo "Ceilometer redeployment completed!"
echo "The blazar_lease resource type should now be registered in Gnocchi."
echo "You can test by creating a new Blazar lease and checking for metrics."