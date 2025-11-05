#!/bin/bash
set -e

echo "Testing Gnocchi attribute naming conventions..."

echo ""
echo "1. First, let's delete the existing resource type:"
echo "openstack metric resource-type delete blazar_lease"

echo ""
echo "2. Test 1: Try with different naming conventions:"
echo "openstack metric resource-type create blazar_lease \\"
echo "  --attribute name:string:true:max_length=255 \\"
echo "  --attribute start_date:string:false:max_length=255 \\"
echo "  --attribute end_date:string:false:max_length=255 \\"
echo "  --attribute projectid:string:true:max_length=255 \\"
echo "  --attribute userid:string:true:max_length=255 \\"
echo "  --attribute lease_id:string:true:max_length=255 \\"
echo "  --attribute lease_status:string:false:max_length=255"

echo ""
echo "3. If that fails, Test 2: Try with camelCase:"
echo "openstack metric resource-type create blazar_lease \\"
echo "  --attribute name:string:true:max_length=255 \\"
echo "  --attribute startDate:string:false:max_length=255 \\"
echo "  --attribute endDate:string:false:max_length=255 \\"
echo "  --attribute projectId:string:true:max_length=255 \\"
echo "  --attribute userId:string:true:max_length=255 \\"
echo "  --attribute leaseId:string:true:max_length=255 \\"
echo "  --attribute leaseStatus:string:false:max_length=255"

echo ""
echo "4. If that fails, Test 3: Try with different separators:"
echo "openstack metric resource-type create blazar_lease \\"
echo "  --attribute name:string:true:max_length=255 \\"
echo "  --attribute start-date:string:false:max_length=255 \\"
echo "  --attribute end-date:string:false:max_length=255 \\"
echo "  --attribute project-id:string:true:max_length=255 \\"
echo "  --attribute user-id:string:true:max_length=255 \\"
echo "  --attribute lease-id:string:true:max_length=255 \\"
echo "  --attribute lease-status:string:false:max_length=255"

echo ""
echo "5. If all fail, Test 4: Check what attributes are allowed by examining existing resource types:"
echo "openstack metric resource-type show instance"

echo ""
echo "6. Based on the results, update the Ceilometer configuration with the correct attribute names"