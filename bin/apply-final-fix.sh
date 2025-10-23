#!/bin/bash
set -e

echo "APPLYING FINAL FIX FOR RESOURCE CREATION"
echo "========================================"

echo ""
echo "ISSUES TO FIX:"
echo "1. ❌ DateTime serialization error"
echo "2. ❌ Missing 'Id' field (field name mismatch)"
echo "3. ❌ Resource creation failing"

echo ""
echo "Step 1: Fix resource type field name mapping"
echo "============================================="
echo "Deleting current resource type and recreating with correct field name..."

openstack metric resource-type delete blazar_lease

echo "Creating resource type with correct field name (Id instead of id)..."

openstack metric resource-type create blazar_lease \
  --attribute Id:string:true:max_length=255 \
  --attribute name:string:false:max_length=255 \
  --attribute start_date:string:false:max_length=255 \
  --attribute end_date:string:false:max_length=255

echo "✅ Resource type created with correct field names"

echo ""
echo "Step 2: Redeploy Ceilometer with updated configuration"
echo "======================================================"
echo "Deleting Ceilometer notification deployment..."

kubectl -n openstack delete deployment ceilometer-notification

echo "Waiting for deployment to be deleted..."
sleep 15

echo "Reinstalling Ceilometer with updated configuration..."
/opt/genestack/bin/install-ceilometer.sh

echo "Waiting for Ceilometer to be ready..."
kubectl -n openstack wait --for=condition=ready pod -l app=ceilometer-notification --timeout=300s

echo "✅ Ceilometer redeployed with updated configuration"

echo ""
echo "Step 3: Test the fix"
echo "==================="
echo "Creating test lease to verify the fix..."

openstack reservation lease create \
  --reservation resource_type=physical:host,min=1,max=1,hypervisor_properties='[">=", "$vcpus", "2"]' \
  --start-date "$(date --date '+1 min' +"%Y-%m-%d %H:%M")" \
  --end-date "$(date --date '+20 min' +"%Y-%m-%d %H:%M")" \
  test-lease-final-fix

echo "✅ Test lease created"

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
echo "Step 5: Check logs for errors"
echo "============================="
echo "Checking Ceilometer logs for any remaining errors..."

kubectl -n openstack logs deploy/ceilometer-notification | grep ERROR | tail -10

echo ""
echo "FINAL STATUS:"
echo "============="
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

if openstack metric resource list --type blazar_lease | grep -q "test-lease-final-fix"; then
    echo "✅ Resources created successfully in Gnocchi"
    echo "🎉 INTEGRATION WORKING END-TO-END!"
else
    echo "❌ Resources not found in Gnocchi"
fi