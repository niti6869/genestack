#!/bin/bash
set -e

echo "Force deploying Ceilometer with updated Blazar configuration..."

# Check if we're in the right environment
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found. Please run this from the correct environment."
    echo "You may need to source the OpenStack RC file first."
    exit 1
fi

echo "Current issues identified:"
echo "1. Event type 'lease.event.start_lease' not defined in current Ceilometer config"
echo "2. Metric 'blazar.lease.start' not handled by Gnocchi"
echo "3. Updated configuration not deployed to running pods"

echo ""
echo "Force redeploying Ceilometer..."

# Delete the existing deployment completely
echo "Deleting existing Ceilometer deployment..."
kubectl -n openstack delete deployment ceilometer-notification || true

# Wait for the deployment to be fully deleted
echo "Waiting for deployment to be deleted..."
sleep 20

# Check if any pods are still running
echo "Checking for remaining pods..."
kubectl -n openstack get pods -l app=ceilometer-notification || true

# Force delete any remaining pods
echo "Force deleting any remaining pods..."
kubectl -n openstack delete pods -l app=ceilometer-notification --force --grace-period=0 || true

# Wait a bit more
echo "Waiting for cleanup to complete..."
sleep 10

# Redeploy Ceilometer with updated configuration
echo "Redeploying Ceilometer with updated configuration..."
/opt/genestack/bin/install-ceilometer.sh

# Wait for pods to be ready
echo "Waiting for Ceilometer pods to be ready..."
kubectl -n openstack wait --for=condition=ready pod -l app=ceilometer-notification --timeout=300s

echo ""
echo "Ceilometer force deployment completed!"
echo ""
echo "Verification steps:"
echo "1. Check that the new configuration is loaded:"
echo "   kubectl -n openstack exec -it deploy/ceilometer-notification -- cat /etc/ceilometer/ceilometer.conf | grep -A 5 'blazar.lease.start'"
echo ""
echo "2. Check that the blazar_lease resource type has all metrics:"
echo "   openstack metric resource-type show blazar_lease"
echo ""
echo "3. Create a new lease and check for metrics:"
echo "   openstack reservation lease create --reservation resource_type=physical:host,min=1,max=1,hypervisor_properties='[\">=\", \"\$vcpus\", \"2\"]' --start-date \"\$(date --date '+1 min' +\"%Y-%m-%d %H:%M\")\" --end-date \"\$(date --date '+20 min' +\"%Y-%m-%d %H:%M\")\" test-lease"
echo ""
echo "4. Check for blazar_lease resources:"
echo "   openstack metric resource list --type blazar_lease"