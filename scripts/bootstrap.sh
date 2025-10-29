#!/bin/bash

set -e

echo "=== DevOps Assignment Bootstrap ==="

# Step 1: Initialize Terraform
echo "Step 1: Initializing Terraform..."
cd terraform
terraform init
echo "Terraform initialized."

# Step 2: Apply Terraform
echo "Step 2: Creating AWS infrastructure..."
terraform apply -auto-approve

# Step 3: Get Terraform Outputs
echo "Step 3: Extracting infrastructure IPs..."
terraform output -json > /tmp/tf_outputs.json

python3 << 'EOF'
import json

with open('/tmp/tf_outputs.json') as f:
    outputs = json.load(f)

controller_ip = outputs['controller_public_ip']['value']
manager_ip = outputs
