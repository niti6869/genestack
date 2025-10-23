#!/bin/bash
set -e

echo "Checking current state of Blazar integration..."

echo ""
echo "1. Current Gnocchi resource type:"
echo "================================="
echo "openstack metric resource-type show blazar_lease"

echo ""
echo "2. Current Ceilometer configuration (check if id field is present):"
echo "==================================================================="
echo "kubectl -n openstack exec -it \$(kubectl -n openstack get pods -l app=ceilometer-notification -o jsonpath='{.items[0].metadata.name}') -- cat /etc/ceilometer/gnocchi_resources.yaml | grep -A 10 blazar_lease"

echo ""
echo "3. Current event definitions:"
echo "============================"
echo "kubectl -n openstack exec -it \$(kubectl -n openstack get pods -l app=ceilometer-notification -o jsonpath='{.items[0].metadata.name}') -- cat /etc/ceilometer/event_definitions.yaml | grep -A 5 -B 5 lease.event"

echo ""
echo "4. Current Ceilometer logs:"
echo "=========================="
echo "kubectl -n openstack logs --tail=20 deploy/ceilometer-notification | grep -i blazar"

echo ""
echo "5. Test lease creation:"
echo "======================"
echo "openstack reservation lease create \\"
echo "  --reservation resource_type=physical:host,min=1,max=1,hypervisor_properties='[\">=\", \"\$vcpus\", \"2\"]' \\"
echo "  --start-date \"\$(date --date '+1 min' +\"%Y-%m-%d %H:%M\")\" \\"
echo "  --end-date \"\$(date --date '+20 min' +\"%Y-%m-%d %H:%M\")\" \\"
echo "  test-lease-check-state"

echo ""
echo "6. Check for resources after lease creation:"
echo "==========================================="
echo "openstack metric resource list --type blazar_lease"

echo ""
echo "7. Check for metrics:"
echo "===================="
echo "openstack metric list | grep -i blazar"

echo ""
echo "EXPECTED ISSUES:"
echo "❌ Resource type probably has 'lease_id' instead of 'id'"
echo "❌ Ceilometer config probably still has old mapping"
echo "❌ Resources probably not created due to 'Required field id not specified' error"
echo "❌ Event types probably not recognized"

echo ""
echo "SOLUTION:"
echo "Run: ./bin/urgent-fix-blazar.sh"