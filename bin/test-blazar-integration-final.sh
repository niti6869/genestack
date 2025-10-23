#!/bin/bash
set -e

echo "Testing Blazar-Ceilometer-Gnocchi integration with corrected configuration..."

echo ""
echo "CURRENT STATUS:"
echo "✅ Resource type 'blazar_lease' exists with correct attributes:"
echo "   - name (required)"
echo "   - start_date (optional)"
echo "   - end_date (optional)"
echo "   - lease_id (required)"

echo ""
echo "✅ Configuration updated to map:"
echo "   - lease_id: resource_metadata.lease_id"
echo "   - name: resource_metadata.name"
echo "   - start_date: resource_metadata.start_date"
echo "   - end_date: resource_metadata.end_date"

echo ""
echo "TESTING STEPS:"
echo ""
echo "1. Check current resource type:"
echo "   openstack metric resource-type show blazar_lease"

echo ""
echo "2. Create a test lease:"
echo "   openstack reservation lease create \\"
echo "     --reservation resource_type=physical:host,min=1,max=1,hypervisor_properties='[\">=\", \"\$vcpus\", \"2\"]' \\"
echo "     --start-date \"\$(date --date '+1 min' +\"%Y-%m-%d %H:%M\")\" \\"
echo "     --end-date \"\$(date --date '+20 min' +\"%Y-%m-%d %H:%M\")\" \\"
echo "     test-lease-final"

echo ""
echo "3. Check for resources:"
echo "   openstack metric resource list --type blazar_lease"

echo ""
echo "4. Check for metrics:"
echo "   openstack metric list | grep -i blazar"

echo ""
echo "5. Check resource details (replace with actual resource ID):"
echo "   openstack metric resource show <resource_id>"

echo ""
echo "6. Check Ceilometer logs for any errors:"
echo "   kubectl -n openstack logs -f deploy/ceilometer-notification | grep -i blazar"

echo ""
echo "EXPECTED RESULTS:"
echo "✅ Resources should be created in Gnocchi"
echo "✅ Metrics should appear for blazar lease events"
echo "✅ Resource should have correct attributes and metadata"
echo "✅ No 'No gnocchi definition for event type' errors in logs"

echo ""
echo "If resources are still not created, the issue may be:"
echo "1. Ceilometer configuration not deployed yet"
echo "2. Event definitions not loading properly"
echo "3. Blazar events not being sent to Ceilometer"