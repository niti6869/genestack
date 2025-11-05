#!/bin/bash
set -e

echo "Fixing attribute mapping mismatch for blazar_lease resource type..."

echo ""
echo "ISSUE IDENTIFIED:"
echo "The resource type has 'lease_id' as a required attribute, but our configuration"
echo "was mapping 'id: resource_metadata.lease_id' instead of 'lease_id: resource_metadata.lease_id'."

echo ""
echo "FIX APPLIED:"
echo "Updated the configuration to map:"
echo "- lease_id: resource_metadata.lease_id (required attribute)"
echo "- name: resource_metadata.name (required attribute)"
echo "- start_date: resource_metadata.start_date (optional attribute)"
echo "- end_date: resource_metadata.end_date (optional attribute)"

echo ""
echo "The following data will be stored in resource_metadata:"
echo "- project_id: resource_metadata.project_id"
echo "- user_id: resource_metadata.user_id"
echo "- status: resource_metadata.status"

echo ""
echo "Next steps:"
echo "1. Redeploy Ceilometer with the corrected configuration"
echo "2. Test creating a lease to verify resources are created"
echo "3. Check that all data is properly stored"

echo ""
echo "To redeploy Ceilometer:"
echo "kubectl -n openstack delete deployment ceilometer-notification"
echo "sleep 15"
echo "/opt/genestack/bin/install-ceilometer.sh"
echo "kubectl -n openstack wait --for=condition=ready pod -l app=ceilometer-notification --timeout=300s"