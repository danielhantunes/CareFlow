variable "aws_region" {
  type        = string
  description = "AWS region for the VPN resources"
  default     = "us-east-1"
}

variable "gcp_project_id" {
  type        = string
  description = "GCP project id"
  default     = "woltrix-careflow-platform"
}

variable "gcp_region" {
  type        = string
  description = "GCP region for VPN resources"
  default     = "us-central1"
}

variable "aws_state_bucket" {
  type        = string
  description = "S3 bucket that stores the AWS Terraform state"
}

variable "aws_state_region" {
  type        = string
  description = "AWS region for the S3 state bucket"
  default     = "us-east-1"
}

variable "aws_state_key" {
  type        = string
  description = "S3 key for the AWS Terraform state"
  default     = "aws/dev/terraform.tfstate"
}

variable "gcp_state_bucket" {
  type        = string
  description = "GCS bucket that stores the GCP Terraform state"
}

variable "gcp_state_prefix" {
  type        = string
  description = "GCS prefix for the GCP Terraform state"
  default     = "gcp/dev"
}

variable "vpn_shared_secret" {
  type        = string
  description = "Pre-shared key for the AWS-GCP VPN tunnel"
  default     = ""
  sensitive   = true
}
