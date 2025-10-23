#!/bin/bash
set -e

echo "Diagnosing Blazar-Ceilometer-Gnocchi integration..."

# Check if we're in the right environment
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found. Please run this from the correct environment."
    echo "You may need to source the OpenStack RC file first."
    exit 1
fi

echo "=== 1. Checking Ceilometer Pod Status ==="
kubectl -n openstack get pods -l app=ceilometer-notification

echo ""
echo "=== 2. Checking Current Ceilometer Configuration ==="
echo "Looking for blazar.lease.start meter definition..."
kubectl -n openstack exec -it deploy/ceilometer-notification -- cat /etc/ceilometer/ceilometer.conf | grep -A 5 -B 5 "blazar.lease.start" || echo "NOT FOUND"

echo ""
echo "Looking for lease.event.start_lease event type..."
kubectl -n openstack exec -it deploy/ceilometer-notification -- cat /etc/ceilometer/ceilometer.conf | grep -A 5 -B 5 "lease.event.start_lease" || echo "NOT FOUND"

echo ""
echo "=== 3. Checking Gnocchi Resource Type ==="
echo "Checking blazar_lease resource type attributes..."
openstack metric resource-type show blazar_lease || echo "Resource type not found"

echo ""
echo "=== 4. Checking for Existing Blazar Resources ==="
echo "Checking for blazar_lease resources..."
openstack metric resource list --type blazar_lease || echo "No resources found"

echo ""
echo "=== 5. Checking for Blazar Metrics ==="
echo "Checking for blazar metrics..."
openstack metric list | grep -i blazar || echo "No blazar metrics found"

echo ""
echo "=== 6. Recent Ceilometer Logs ==="
echo "Checking recent Ceilometer logs for Blazar events..."
kubectl -n openstack logs --tail=20 deploy/ceilometer-notification | grep -i "blazar\|lease" || echo "No recent Blazar events in logs"

echo ""
echo "=== Diagnosis Complete ==="
echo "If you see 'NOT FOUND' or 'No resources found' above, the configuration needs to be deployed."
echo "Run: ./bin/force-deploy-ceilometer.sh"