variable "project_id" {
  type        = string
  description = "GCP project id"
  default     = "woltrix-careflow-platform"
}

variable "region" {
  type        = string
  description = "GCP region"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "GCP zone for the VM"
  default     = "us-central1-a"
}

variable "network_name" {
  type        = string
  description = "VPC name"
  default     = "careflow-vpc"
}

variable "subnet_name" {
  type        = string
  description = "Subnet name"
  default     = "careflow-private-subnet"
}

variable "subnet_cidr" {
  type        = string
  description = "Subnet CIDR"
  default     = "10.10.0.0/24"
}

variable "vm_name" {
  type        = string
  description = "VM name"
  default     = "careflow-private-vm-01"
}

variable "machine_type" {
  type        = string
  description = "Machine type (micro)"
  default     = "e2-micro"
}

variable "labels" {
  type        = map(string)
  description = "Resource labels"
  default = {
    project = "careflow"
    env     = "dev"
  }
}
