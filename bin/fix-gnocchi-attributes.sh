#!/bin/bash
set -e

echo "Fixing Gnocchi attribute naming for blazar_lease resource type..."

echo ""
echo "The issue is that Gnocchi has restrictions on attribute names."
echo "We need to find the correct naming convention that works."

echo ""
echo "Step 1: Delete existing resource type"
echo "openstack metric resource-type delete blazar_lease"

echo ""
echo "Step 2: Test with basic attributes that we know work"
echo "openstack metric resource-type create blazar_lease \\"
echo "  --attribute name:string:true:max_length=255 \\"
echo "  --attribute start_date:string:false:max_length=255 \\"
echo "  --attribute end_date:string:false:max_length=255"

echo ""
echo "Step 3: If that works, try adding more attributes one by one"
echo "openstack metric resource-type create blazar_lease \\"
echo "  --attribute name:string:true:max_length=255 \\"
echo "  --attribute start_date:string:false:max_length=255 \\"
echo "  --attribute end_date:string:false:max_length=255 \\"
echo "  --attribute lease_id:string:true:max_length=255"

echo ""
echo "Step 4: Check what attributes are actually used in existing resource types"
echo "openstack metric resource-type show instance"

echo ""
echo "Step 5: Based on the results, update the Ceilometer configuration"
echo "The configuration should use the attribute names that actually work in Gnocchi."

echo ""
echo "Current configuration uses:"
echo "- id: resource_metadata.lease_id"
echo "- name: resource_metadata.name"
echo "- project_id: resource_metadata.project_id"
echo "- user_id: resource_metadata.user_id"
echo "- start_date: resource_metadata.start_date"
echo "- end_date: resource_metadata.end_date"
echo "- status: resource_metadata.status"

echo ""
echo "We need to find which of these are actually supported by Gnocchi."