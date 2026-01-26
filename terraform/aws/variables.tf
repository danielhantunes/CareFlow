variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "careflow"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.20.0.0/16"
}

variable "subnet_cidr" {
  type        = string
  description = "Private subnet CIDR block"
  default     = "10.20.1.0/24"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "tags" {
  type        = map(string)
  description = "Common resource tags"

  default = {
    project = "careflow"
    env     = "dev"
  }

  validation {
    condition     = contains(keys(var.tags), "project")
    error_message = "The 'project' tag is required (e.g. project = \"careflow\")."
  }
}

