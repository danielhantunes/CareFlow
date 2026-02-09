variable "project_id" {
  type        = string
  description = "GCP project id"
  default     = "woltrix-careflow-platform"
}

variable "state_bucket_name" {
  type        = string
  description = "GCS bucket name for Terraform remote state"
}

variable "location" {
  type        = string
  description = "GCS bucket location"
  default     = "us-central1"
}

variable "labels" {
  type        = map(string)
  description = "Common labels for bootstrap resources"
  default = {
    project    = "careflow"
    managed_by = "terraform"
  }
}
