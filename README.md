## Project Status
🚧 This project is under active development.

CareFlow demonstrates end-to-end data engineering infrastructure patterns with a focus on
secure, private, cloud-native architectures using Terraform. The repository is structured
to support multi-cloud deployments and repeatable environments.

---

# CareFlow Infrastructure

CareFlow is a multi-cloud infrastructure project designed to showcase best practices for
provisioning secure, private, and scalable environments that support data engineering workloads.

Key principles:
- Private networking by default
- Infrastructure as Code (Terraform)
- Secure access patterns (no SSH, no public IPs)
- Cloud-agnostic architectural principles (AWS and GCP)

---

## Repository Structure

```
.github/
  workflows/
    terraform-bootstrap.yml
    terraform-infra.yml
terraform/
  aws/
    backend.tf
    main.tf
    outputs.tf
    providers.tf
    terraform.tfvars.example
    variables.tf
    versions.tf
  bootstrap/
    main.tf
    variables.tf
  gcp/
    main.tf
    outputs.tf
    providers.tf
    terraform.tfvars.example
    variables.tf
    versions.tf
README.md
```

---

## Terraform Modules

### Bootstrap (remote state baseline)
**Location:** `terraform/bootstrap`

Purpose:
- Baseline resources needed for Terraform state management
- Keep bootstrap isolated from environment-specific infrastructure

### AWS — Private VPC with EC2 (SSM-only access)
**Location:** `terraform/aws`

What is provisioned:
- 1 VPC with DNS support enabled
- 1 private subnet (no public IPs)
- 1 private EC2 instance (`t2.micro`) with IMDSv2 enforced
- Security groups with no inbound access
- Interface VPC endpoints for AWS Systems Manager (SSM)
- IAM role and instance profile for secure SSM access

Design principles:
- Instances are not exposed to the internet
- No SSH access; connectivity is via AWS Systems Manager
- Suitable for internal batch/data workloads

### GCP — Private networking baseline
**Location:** `terraform/gcp`

What is provisioned:
- Private networking primitives and outputs for downstream workloads
- GCP-specific provider and version pinning

---

## GitHub Actions

**Location:** `.github/workflows`

Workflows:
- `terraform-bootstrap.yml` for bootstrap initialization
- `terraform-infra.yml` for main infrastructure plans/applies

---

## Prerequisites

- Terraform >= 1.5
- Cloud credentials configured for your target provider
- Permissions to create networking and IAM resources

---

## Region Selection

Default regions:
- AWS: `us-east-1` (broad service coverage and competitive pricing)
- GCP: `us-central1` (broad service coverage and competitive pricing)

These choices are generally cost-effective for development workloads. Cost is a valid reason to pick a
default region, but it is not the only one. When choosing a region, also consider:
- Service availability (not all services are in every region)
- Data residency and compliance requirements
- Latency to users or downstream systems

You can override the region in your `terraform.tfvars` to fit your environment.

---

## Usage (example)

1. Copy the example variables file for your target cloud:
   - AWS (PowerShell): `copy terraform/aws/terraform.tfvars.example terraform/aws/terraform.tfvars`
   - GCP (PowerShell): `copy terraform/gcp/terraform.tfvars.example terraform/gcp/terraform.tfvars`

2. Initialize and apply:
   ```bash
   terraform -chdir=terraform/<cloud> init
   terraform -chdir=terraform/<cloud> plan
   terraform -chdir=terraform/<cloud> apply
   ```

Replace `<cloud>` with `aws` or `gcp`.
