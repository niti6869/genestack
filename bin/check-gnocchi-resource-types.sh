#!/bin/bash
set -e

echo "Checking Gnocchi resource types..."

# Check if we can access the OpenStack environment
if ! command -v openstack &> /dev/null; then
    echo "OpenStack CLI not found. Please source the OpenStack RC file first."
    echo "Run: source /opt/genestack/bin/setup-openstack-rc.sh"
    exit 1
fi

echo "Listing all resource types in Gnocchi:"
openstack metric resource-type list

echo ""
echo "Checking specifically for blazar_lease resource type:"
if openstack metric resource-type show blazar_lease &> /dev/null; then
    echo "✅ blazar_lease resource type exists"
    openstack metric resource-type show blazar_lease
else
    echo "❌ blazar_lease resource type does not exist"
    echo "This is why Ceilometer cannot create blazar_lease resources."
    echo "The resource type needs to be registered by Ceilometer."
fi

echo ""
echo "Checking for existing blazar_lease resources:"
openstack metric resource list --type blazar_lease