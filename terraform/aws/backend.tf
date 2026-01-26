terraform {
  backend "s3" {
    bucket         = "careflow-terraform-state-767397900909"
    key            = "aws/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
