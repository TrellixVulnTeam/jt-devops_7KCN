#!/bin/sh

ADMIN_PASSWORD="xlHGWJb0nPMJI3"

echo "Generating common users..."
useradd admin
echo "xlHGWJb0nPMJI3"|passwd --stdin admin && history -c