provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "careflow-terraform-state-767397900909"

  versioning {
    enabled = true
  }

  tags = {
    project    = "careflow"
    managed_by = "terraform"
  }
}

resource "aws_dynamodb_table" "tf_locks" {
  name         = "terraform-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    project    = "careflow"
    managed_by = "terraform"
  }
}
