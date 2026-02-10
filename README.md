## Project Status
🚧 This project is under active development and continuously evolving.
The current state already reflects production-oriented design decisions.

CareFlow demonstrates end-to-end data engineering infrastructure patterns with a focus on
secure, private, cloud-native architectures using Terraform. The repository is structured
to support multi-cloud deployments and repeatable environments.

⚠️ This project provisions real cloud resources and may incur costs.
Review the Terraform plan carefully before applying.

---

# CareFlow Infrastructure

CareFlow demonstrates how modern data platforms can be built on top of secure, private
infrastructure foundations, emphasizing reproducibility, cloud neutrality, and security-first
access patterns.

Key principles:
- Private networking by default (zero-trust mindset)
- Infrastructure as Code (Terraform)
- Secure access patterns (no SSH, no public IPs)
- Cloud-agnostic architectural principles (AWS and GCP)
- Designed for extensibility toward data engineering workloads

---

## Repository Structure

```
.github/
  workflows/
    terraform-bootstrap-aws.yml
    terraform-bootstrap-gcp.yml
    terraform-infra-aws.yml
    terraform-infra-gcp.yml
terraform/
  aws/
    backend.tf
    main.tf
    outputs.tf
    providers.tf
    terraform.tfvars.example
    variables.tf
    versions.tf
  azure/
    main.tf
    outputs.tf
    providers.tf
    terraform.tfvars.example
    variables.tf
    versions.tf
  bootstrap/
    main.tf
    outputs.tf
    terraform.tfvars.example
    variables.tf
  bootstrap-gcp/
    main.tf
    outputs.tf
    terraform.tfvars.example
    variables.tf
  connectivity-aws-gcp/
    backend.tf
    main.tf
    outputs.tf
    terraform.tfvars.example
    variables.tf
    versions.tf
  gcp/
    backend.tf
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
**Locations:**
- AWS: `terraform/bootstrap`
- GCP: `terraform/bootstrap-gcp`

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
- Suitable for internal batch, ETL, or data processing workloads where
  network isolation and controlled access are required

### GCP — Private networking baseline
**Location:** `terraform/gcp`

What is provisioned:
- Private networking primitives and outputs for downstream workloads
- GCP-specific provider and version pinning

### Azure — Placeholder module
**Location:** `terraform/azure`

What is provisioned:
- Placeholder files for future Azure infrastructure

### AWS ↔ GCP Connectivity (site-to-site VPN)
**Location:** `terraform/connectivity-aws-gcp`

What is provisioned:
- AWS VPN gateway, customer gateway, VPN connection, and routes
- GCP classic VPN gateway, forwarding rules, VPN tunnel, and route
- ICMP allow rules for cross-cloud ping testing

Design notes:
- Uses Terraform remote state outputs from `terraform/aws` and `terraform/gcp`
- Intended for short-term AWS↔GCP connectivity validation and testing
 - The initial implementation uses a static site-to-site VPN between AWS and GCP to validate cross-cloud private connectivity and support early pipeline experimentation.
 - As the platform evolves and additional clouds are introduced, this connectivity layer is designed to transition to HA VPN with BGP-based dynamic routing to provide resilient, scalable multicloud networking.

---

## GitHub Actions

**Location:** `.github/workflows`

Workflows:
- `terraform-bootstrap-aws.yml` for AWS bootstrap initialization
- `terraform-bootstrap-gcp.yml` for GCP bootstrap initialization
- `terraform-infra-aws.yml` for AWS infrastructure plans/applies
- `terraform-infra-gcp.yml` for GCP infrastructure plans/applies

Required GitHub Actions variables (AWS):
- `AWS_ROLE_ARN` (OIDC role to assume)
- `STATE_BUCKET_NAME` (S3 bucket for Terraform remote state)

Required GitHub Actions variables (GCP):
- `GCP_WORKLOAD_IDENTITY_PROVIDER` (Workload Identity Provider resource)
- `GCP_SERVICE_ACCOUNT` (Service account email to impersonate)
- `GCP_STATE_BUCKET` (GCS bucket for Terraform remote state)

Optional GitHub Actions variables:
- `AWS_REGION` (target AWS region, default: `us-east-1`)
- `LOCK_TABLE_NAME` (DynamoDB table for state locking, default: `terraform-state-locks`)
- `GCP_PROJECT_ID` (target GCP project id)
- `GCP_STATE_PREFIX` (GCS state prefix, default: `gcp/dev/terraform.tfstate`)
- `GCP_STATE_LOCATION` (GCS bucket location, default: `US`)

Set these as GitHub Actions variables under Settings → Secrets and variables → Actions → Variables.

Safe to publish:
- Document variable names, not real values
- Use placeholders in public docs, for example:
  - `AWS_ROLE_ARN=arn:aws:iam::<account-id>:role/<role-name>`
  - `STATE_BUCKET_NAME=<aws-state-bucket>`
  - `GCP_WORKLOAD_IDENTITY_PROVIDER=projects/<project-number>/locations/global/workloadIdentityPools/<pool>/providers/<provider>`
  - `GCP_SERVICE_ACCOUNT=<sa-name>@<project-id>.iam.gserviceaccount.com`
  - `GCP_STATE_BUCKET=<gcp-state-bucket>`

Bootstrap and infra workflow order:
- Run `terraform-bootstrap-aws.yml` with `terraform_action=apply` to create the S3 bucket and lock table
- Run `terraform-bootstrap-gcp.yml` with `terraform_action=apply` to create the GCS bucket
- Run `terraform-infra-aws.yml` with `action=apply` to create infrastructure state in S3
- Run `terraform-infra-aws.yml` with `action=destroy` to tear down AWS infrastructure
- Run `terraform-infra-gcp.yml` with `action=apply` to create infrastructure state in GCS
- Run `terraform-infra-gcp.yml` with `action=destroy` to tear down GCP infrastructure

---

## Remote State Design

CareFlow uses:
- AWS: S3 for Terraform state storage and DynamoDB for state locking
- GCP: GCS for Terraform state storage

Why AWS uses both:
- S3 stores Terraform's memory (resource IDs and dependencies)
- DynamoDB prevents concurrent runs from corrupting state

This is the standard production pattern used in AWS environments.

---

## CI/CD Authentication with OIDC

CareFlow uses GitHub Actions with AWS OpenID Connect (OIDC) to authenticate
Terraform workflows without long-lived AWS credentials.

An IAM OIDC identity provider is configured in the AWS account to trust
`token.actions.githubusercontent.com`. GitHub Actions then assumes the
`gh-actions-terraform` role at runtime using short-lived credentials via
`sts:AssumeRoleWithWebIdentity`.

Benefits:
- No long-lived AWS keys
- Short-lived credentials
- Auditable access
- Least privilege

This approach reflects modern production security practices for data platforms.
An active AWS account is required to configure the OIDC provider and IAM role.

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
 - GCP bootstrap state bucket: `us-central1`

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
