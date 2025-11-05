#!/bin/bash
set -e

echo "Fixing resource ID mapping for blazar_lease resource type..."

echo ""
echo "ISSUE IDENTIFIED:"
echo "Ceilometer expects 'id' field but our resource type has 'lease_id'"
echo "Error: Required field id not specified"

echo ""
echo "FIXES APPLIED:"
echo "1. ✅ Changed attribute mapping from 'lease_id: resource_metadata.lease_id' to 'id: resource_metadata.lease_id'"
echo "2. ✅ Updated event_attributes from 'lease_id: lease_id' to 'id: lease_id'"
echo "3. ✅ Need to update Gnocchi resource type to use 'id' instead of 'lease_id'"

echo ""
echo "NEXT STEPS:"
echo "1. Delete the existing resource type with wrong attributes"
echo "2. Create new resource type with correct 'id' attribute"
echo "3. Redeploy Ceilometer with corrected configuration"

echo ""
echo "Commands to fix the resource type:"
echo ""
echo "# Delete existing resource type"
echo "openstack metric resource-type delete blazar_lease"
echo ""
echo "# Create new resource type with correct attributes"
echo "openstack metric resource-type create blazar_lease \\"
echo "  --attribute id:string:true:max_length=255 \\"
echo "  --attribute name:string:true:max_length=255 \\"
echo "  --attribute start_date:string:false:max_length=255 \\"
echo "  --attribute end_date:string:false:max_length=255"

echo ""
echo "Then redeploy Ceilometer:"
echo "kubectl -n openstack delete deployment ceilometer-notification"
echo "sleep 15"
echo "/opt/genestack/bin/install-ceilometer.sh"
echo "kubectl -n openstack wait --for=condition=ready pod -l app=ceilometer-notification --timeout=300s"

echo ""
echo "EXPECTED RESULT:"
echo "✅ No more 'Required field id not specified' errors"
echo "✅ Resources should be created successfully in Gnocchi"
echo "✅ All lease events should be processed correctly"