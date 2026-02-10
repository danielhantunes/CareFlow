terraform {
  backend "s3" {
    key     = "connectivity/aws-gcp/terraform.tfstate"
    encrypt = true
  }
}
