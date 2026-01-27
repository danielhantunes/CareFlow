## Project Status
🚧 This project is under active development.

This repository demonstrates end-to-end data engineering and cloud infrastructure concepts,
with a focus on secure, cloud-native architectures using Infrastructure as Code (Terraform).
New features, architectural improvements, and documentation are continuously added as the
project evolves.

---

# CareFlow Infrastructure

CareFlow is a multi-cloud infrastructure project designed to showcase best practices for
provisioning secure, private, and scalable environments that support data engineering workloads.

The project focuses on:
- Private networking by default
- Infrastructure as Code (Terraform)
- Secure access patterns (no SSH, no public IPs)
- Cloud-agnostic architectural principles (AWS and GCP)

---

## AWS — Private VPC with EC2 (SSM-only access)

**Location:** `terraform/aws`

### What is provisioned
- 1 VPC with DNS support enabled
- 1 private subnet (no public IPs)
- 1 private EC2 instance (`t2.micro`) with IMDSv2 enforced
- Security groups with no inbound access
- Interface VPC endpoints for AWS Systems Manager (SSM)
- IAM role and instance profile for secure SSM access

### Design principles
- Instances are **not exposed to the internet**
- No SSH access; all connectivity is handled via **AWS Systems Manager**
- Designed for running batch jobs, agents, or internal data workloads

### Prerequisites
- Terraform >= 1.5
- AWS credentials configured (via `aws configure` or environment variables)
- Permissions to create VPC, EC2, IAM, and VPC endpoints

### Usage
1. Copy the example variables file:
   ```bash
   copy terraform/aws/terraform.tfvars.example terraform/aws/terraform.tfvars

