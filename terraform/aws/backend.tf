terraform {
  backend "s3" {
    key            = "aws/dev/terraform.tfstate"
    encrypt        = true
  }
}
