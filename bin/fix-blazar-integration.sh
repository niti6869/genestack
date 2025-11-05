#!/bin/bash
set -e

echo "Fixing Blazar-Ceilometer-Gnocchi integration..."

# Check if we're in the right environment
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found. Please run this from the correct environment."
    echo "You may need to source the OpenStack RC file first."
    exit 1
fi

echo "Current issues identified:"
echo "1. Missing event types: lease.event.before_end_lease, lease.delete"
echo "2. Missing meter definitions for some event types"
echo "3. Resource type missing critical attributes (id, project_id, user_id, status)"
echo "4. Updated configuration not deployed to running pods"

echo ""
echo "Configuration fixes applied:"
echo "✅ Added missing event types: lease.event.before_end_lease, lease.event.start_lease, lease.event.end_lease"
echo "✅ Added missing meter definition: blazar.lease.delete"
echo "✅ Updated meter definitions to handle lease.event.* events"
echo "✅ Added status attribute to blazar_lease resource type"
echo "✅ All event types now properly mapped"

echo ""
echo "Redeploying Ceilometer with updated configuration..."

# Delete existing Ceilometer deployment to force fresh deployment
echo "Deleting existing Ceilometer deployment..."
kubectl -n openstack delete deployment ceilometer-notification || true

# Wait for deployment to be fully deleted
echo "Waiting for deployment to be deleted..."
sleep 15

# Redeploy Ceilometer with updated configuration
echo "Redeploying Ceilometer with updated configuration..."
/opt/genestack/bin/install-ceilometer.sh

# Wait for pods to be ready
echo "Waiting for Ceilometer pods to be ready..."
kubectl -n openstack wait --for=condition=ready pod -l app=ceilometer-notification --timeout=300s

echo ""
echo "Ceilometer redeployment completed!"
echo ""
echo "Next steps:"
echo "1. Check that blazar_lease resource type now has all attributes:"
echo "   openstack metric resource-type show blazar_lease"
echo ""
echo "2. Create a new Blazar lease and check for metrics:"
echo "   openstack reservation lease create --reservation resource_type=physical:host,min=1,max=1,hypervisor_properties='[\">=\", \"\$vcpus\", \"2\"]' --start-date \"\$(date --date '+1 min' +\"%Y-%m-%d %H:%M\")\" --end-date \"\$(date --date '+20 min' +\"%Y-%m-%d %H:%M\")\" test-lease"
echo ""
echo "3. Check for blazar_lease resources:"
echo "   openstack metric resource list --type blazar_lease"
echo ""
echo "4. Check for blazar metrics:"
echo "   openstack metric list | grep -i blazar"