# Udagram Infrastructure as Code Project

This project deploys a highly available web application infrastructure on AWS using CloudFormation templates. The infrastructure includes networking components, load balancers, auto-scaling groups, and an S3 bucket for static content.

## Infrastructure Diagram

[View Infrastructure Diagram](https://lucid.app/lucidchart/dc556751-3533-4db1-8f92-cad02b9caa91/edit?viewport_loc=-880%2C-404%2C3351%2C1821%2C0_0&invitationId=inv_b882e23c-c8e6-4c9b-8ad0-d73ada502c1f)

## Architecture Overview

- **Network**: VPC with 2 public and 2 private subnets across 2 availability zones
- **Compute**: Auto Scaling Group with 4 EC2 instances (t2.micro, Ubuntu 22) distributed across private subnets
- **Load Balancing**: Application Load Balancer in public subnets
- **Storage**: S3 bucket for static website content
- **Security**: Security groups configured for HTTP traffic on port 80

## Prerequisites

- AWS CLI installed and configured with appropriate credentials
- IAM permissions to create CloudFormation stacks, VPC, EC2, ALB, and S3 resources
- Bash shell environment

## Project Structure

```
starter/
├── network.yml                 # Network infrastructure template
├── udagram.yml                 # Application infrastructure template
├── udagram-parameters.json     # Parameters for both templates
├── create.sh                   # Script to create CloudFormation stacks
├── update.sh                   # Script to update CloudFormation stacks
├── delete.sh                   # Script to delete CloudFormation stacks
└── README.md                   # This file
```

## Deployment Instructions

### Step 1: Create Network Infrastructure

Deploy the networking stack first as the application stack depends on its outputs:

```bash
cd starter/
./create.sh udagram-network network.yml udagram-parameters.json
```

### Step 2: Upload Static Content to S3

Before deploying the application stack, upload your static website content to S3:

```bash
# Create a simple index.html file
echo "<h1>It works! Udagram, Udacity</h1>" > index.html

# Upload to S3 bucket (bucket name: udacity-s3-bmg-1612)
aws s3 cp index.html s3://udacity-s3-bmg-1612/
```

### Step 3: Create Application Infrastructure

Deploy the application stack:

```bash
./create.sh udagram-app udagram.yml udagram-parameters.json
```

### Step 4: Verify Deployment

1. Check stack status in AWS CloudFormation console
2. Get the Load Balancer URL from the stack outputs:
   ```bash
   aws cloudformation describe-stacks --stack-name udagram-app --query 'Stacks[0].Outputs'
   ```
3. Access the website using the Load Balancer URL

## Updating Infrastructure

To update existing stacks with changes:

```bash
# Update network stack
./update.sh udagram-network network.yml udagram-parameters.json

# Update application stack
./update.sh udagram-app udagram.yml udagram-parameters.json
```

## Deletion Instructions

**Important**: Delete stacks in reverse order to avoid dependency conflicts.

### Step 1: Delete Application Stack

```bash
./delete.sh udagram-app
```

Wait for deletion to complete:
```bash
aws cloudformation wait stack-delete-complete --stack-name udagram-app
```

### Step 2: Empty S3 Bucket

```bash
# Empty S3 bucket before deleting the stack
aws s3 rm s3://udacity-s3-bmg-1612 --recursive
```

### Step 3: Delete Network Stack

```bash
./delete.sh udagram-network
```

Wait for deletion to complete:
```bash
aws cloudformation wait stack-delete-complete --stack-name udagram-network
```

## Parameters Configuration

The `udagram-parameters.json` file contains the following configurable parameters:

- **EnvironmentName**: Prefix for all resource names
- **VpcCIDR**: IP range for the VPC (default: 10.0.0.0/16)
- **PublicSubnet1CIDR**: Public subnet in AZ1 (default: 10.0.0.0/24)
- **PublicSubnet2CIDR**: Public subnet in AZ2 (default: 10.0.1.0/24)
- **PrivateSubnet1CIDR**: Private subnet in AZ1 (default: 10.0.2.0/24)
- **PrivateSubnet2CIDR**: Private subnet in AZ2 (default: 10.0.3.0/24)

## Security Features

- Web servers are deployed in private subnets with no direct internet access
- Load balancer in public subnets handles all incoming traffic
- Security groups restrict access to HTTP port 80 only
- NAT gateways provide outbound internet access for updates
- S3 bucket configured with encryption and proper access controls

## High Availability

- Resources distributed across 2 availability zones
- Auto Scaling Group maintains 4 instances (minimum 4, desired 4, maximum 6)
- Application Load Balancer performs health checks
- Multiple NAT gateways for redundancy

## Evidence of Deployment

The website is live and can be accessed at: 

**http://udacit-webap-c4bmaool8heo-208616444.us-east-1.elb.amazonaws.com/**

The website displays: "It works! Udagram, Udacity" and serves content from EC2 instances with S3 integration.

## Author

Bruno - Udacity Infrastructure as Code Project