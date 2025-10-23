#!/bin/bash
set -e

echo "Fixing Ceilometer event definitions loading..."

# Check if we're in the right environment
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found. Please run this from the correct environment."
    echo "You may need to source the OpenStack RC file first."
    exit 1
fi

echo "Issues identified:"
echo "1. Event definitions are not being loaded from file"
echo "2. Ceilometer needs to be configured to load event_definitions.yaml"
echo "3. Added event.definitions_file configuration to Ceilometer"

echo ""
echo "Redeploying Ceilometer with event definitions file configuration..."

# Delete the existing deployment
echo "Deleting existing Ceilometer deployment..."
kubectl -n openstack delete deployment ceilometer-notification || true

# Wait for cleanup
echo "Waiting for cleanup to complete..."
sleep 15

# Redeploy with corrected configuration
echo "Redeploying Ceilometer with event definitions file configuration..."
/opt/genestack/bin/install-ceilometer.sh

# Wait for pods to be ready
echo "Waiting for Ceilometer pods to be ready..."
kubectl -n openstack wait --for=condition=ready pod -l app=ceilometer-notification --timeout=300s

echo ""
echo "Ceilometer redeployment completed!"
echo ""
echo "Verification steps:"
echo "1. Check that event definitions are loaded:"
echo "   kubectl -n openstack exec -it deploy/ceilometer-notification -- cat /etc/ceilometer/event_definitions.yaml | grep -A 5 'blazar.lease'"
echo ""
echo "2. Check that the blazar_lease resource type has all attributes:"
echo "   openstack metric resource-type show blazar_lease"
echo ""
echo "3. Create a new lease and check for metrics:"
echo "   openstack reservation lease create --reservation resource_type=physical:host,min=1,max=1,hypervisor_properties='[\">=\", \"\$vcpus\", \"2\"]' --start-date \"\$(date --date '+1 min' +\"%Y-%m-%d %H:%M\")\" --end-date \"\$(date --date '+20 min' +\"%Y-%m-%d %H:%M\")\" test-lease"
echo ""
echo "4. Check for blazar_lease resources:"
echo "   openstack metric resource list --type blazar_lease"
echo ""
echo "5. Check for blazar metrics:"
echo "   openstack metric list | grep -i blazar"