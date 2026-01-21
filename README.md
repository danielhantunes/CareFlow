# CareFlow Infrastructure

This repository contains Terraform configurations for infrastructure provisioning.

## AWS (Private VPC + EC2)

Location: `terraform/aws`

### What gets created
- 1 VPC with DNS support enabled
- 1 private subnet (no public IPs)
- Private EC2 instance (`t2.micro`) with IMDSv2 required
- Security groups with no inbound access to the instance
- Interface VPC endpoints for AWS Systems Manager (SSM)
- IAM role and instance profile for SSM access

### Prerequisites
- Terraform >= 1.5
- AWS credentials configured (e.g. `aws configure` or environment variables)
- Permission to create VPC, EC2, IAM, and VPC endpoints

### Usage
1. Copy the example variables file:
   - `copy terraform/aws/terraform.tfvars.example terraform/aws/terraform.tfvars`
2. Initialize and apply:
   - `cd terraform/aws`
   - `terraform init`
   - `terraform apply`

### Notes
- The subnet is private-only and has no internet access.
- Use Session Manager to access the instance:
  - `aws ssm start-session --target <instance-id>`

## GCP

Location: `terraform/gcp`

Contains a private VPC, subnet, Cloud NAT, and a private VM (see directory for details).
