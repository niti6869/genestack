#!/bin/bash
set -e

echo "Testing event type recognition fix..."

echo ""
echo "FIXES APPLIED:"
echo "1. ✅ Added 'lease.event.before_end_lease' to event_update triggers"
echo "2. ✅ Fixed 'blazar.lease.end' meter definition (added missing fields)"
echo "3. ✅ Added 'lease.event.start_lease' to event_create triggers"
echo "4. ✅ All meter definitions now have complete type, unit, volume, project_id, user_id, resource_id"

echo ""
echo "EXPECTED RESULTS AFTER REDEPLOYMENT:"
echo "✅ No more 'No gnocchi definition for event type' errors"
echo "✅ No more 'metric blazar.lease.* is not handled by Gnocchi' warnings"
echo "✅ Resources should be created in Gnocchi for all lease events"
echo "✅ Metrics should be properly stored and queryable"

echo ""
echo "TESTING STEPS:"
echo ""
echo "1. First, redeploy Ceilometer:"
echo "   kubectl -n openstack delete deployment ceilometer-notification"
echo "   sleep 15"
echo "   /opt/genestack/bin/install-ceilometer.sh"
echo "   kubectl -n openstack wait --for=condition=ready pod -l app=ceilometer-notification --timeout=300s"

echo ""
echo "2. Create a test lease:"
echo "   openstack reservation lease create \\"
echo "     --reservation resource_type=physical:host,min=1,max=1,hypervisor_properties='[\">=\", \"\$vcpus\", \"2\"]' \\"
echo "     --start-date \"\$(date --date '+1 min' +\"%Y-%m-%d %H:%M\")\" \\"
echo "     --end-date \"\$(date --date '+20 min' +\"%Y-%m-%d %H:%M\")\" \\"
echo "     test-lease-event-fix"

echo ""
echo "3. Monitor Ceilometer logs for success:"
echo "   kubectl -n openstack logs -f deploy/ceilometer-notification | grep -i blazar"

echo ""
echo "4. Check for resources:"
echo "   openstack metric resource list --type blazar_lease"

echo ""
echo "5. Check for metrics:"
echo "   openstack metric list | grep -i blazar"

echo ""
echo "SUCCESS INDICATORS:"
echo "✅ No 'No gnocchi definition for event type' errors in logs"
echo "✅ No 'metric blazar.lease.* is not handled by Gnocchi' warnings"
echo "✅ Resources appear in 'openstack metric resource list --type blazar_lease'"
echo "✅ Metrics appear in 'openstack metric list | grep -i blazar'"