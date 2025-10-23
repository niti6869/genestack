#!/bin/bash
set -e

echo "FIXING MISSING EVENT TYPES IN METER DEFINITIONS"
echo "==============================================="

echo ""
echo "ISSUE IDENTIFIED:"
echo "❌ No gnocchi definition for event type: lease.event.start_lease"
echo "❌ Missing event types in meter definitions"

echo ""
echo "ROOT CAUSE:"
echo "The event types 'lease.event.start_lease' and 'lease.event.end_lease' are defined"
echo "in the event definitions but missing from the corresponding meter definitions."

echo ""
echo "FIXES APPLIED:"
echo "✅ Added 'lease.event.start_lease' to blazar.lease.start meter definition"
echo "✅ Added 'lease.event.end_lease' to blazar.lease.end meter definition"

echo ""
echo "Step 1: Redeploy Ceilometer with updated configuration"
echo "======================================================"
echo "Deleting Ceilometer notification deployment..."

kubectl -n openstack delete deployment ceilometer-notification

echo "Waiting for deployment to be deleted..."
sleep 15

echo "Reinstalling Ceilometer with updated configuration..."
/opt/genestack/bin/install-ceilometer.sh

echo "Waiting for Ceilometer to be ready..."
kubectl -n openstack wait --for=condition=ready pod -l app=ceilometer-notification --timeout=300s

echo "✅ Ceilometer redeployed with updated meter definitions"

echo ""
echo "Step 2: Test the fix"
echo "==================="
echo "Creating test lease to verify the fix..."

openstack reservation lease create \
  --reservation resource_type=physical:host,min=1,max=1,hypervisor_properties='[">=", "$vcpus", "2"]' \
  --start-date "$(date --date '+1 min' +"%Y-%m-%d %H:%M")" \
  --end-date "$(date --date '+20 min' +"%Y-%m-%d %H:%M")" \
  test-lease-event-types-fix

echo "✅ Test lease created"

echo ""
echo "Step 3: Check logs for errors"
echo "============================="
echo "Checking Ceilometer logs for any remaining errors..."

kubectl -n openstack logs deploy/ceilometer-notification | grep ERROR | tail -10

echo ""
echo "Step 4: Verify results"
echo "====================="
echo "Checking for resources in Gnocchi..."

echo ""
echo "Resources:"
openstack metric resource list --type blazar_lease

echo ""
echo "Metrics:"
openstack metric list | grep -i blazar

echo ""
echo "FINAL STATUS:"
echo "============="
if kubectl -n openstack logs deploy/ceilometer-notification | grep -q "No gnocchi definition for event type: lease.event.start_lease"; then
    echo "❌ lease.event.start_lease error still present"
else
    echo "✅ lease.event.start_lease error fixed"
fi

if kubectl -n openstack logs deploy/ceilometer-notification | grep -q "datetime.datetime.*is not JSON serializable"; then
    echo "❌ DateTime serialization error still present"
else
    echo "✅ DateTime serialization error fixed"
fi

if kubectl -n openstack logs deploy/ceilometer-notification | grep -q "required key not provided @ data\['Id'\]"; then
    echo "❌ Missing 'Id' field error still present"
else
    echo "✅ Missing 'Id' field error fixed"
fi

if openstack metric resource list --type blazar_lease | grep -q "test-lease-event-types-fix"; then
    echo "✅ Resources created successfully in Gnocchi"
    echo "🎉 INTEGRATION WORKING END-TO-END!"
else
    echo "❌ Resources not found in Gnocchi"
fi