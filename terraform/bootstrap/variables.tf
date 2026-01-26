variable "aws_region" {
  description = "AWS region where the Terraform state backend lives"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform remote state"
  type        = string
}

variable "lock_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = "terraform-state-locks"
}

variable "tags" {
  description = "Common tags for bootstrap resources"
  type        = map(string)
  default = {
    project    = "careflow"
    managed_by = "terraform"
  }
}
