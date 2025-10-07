terraform {
  required_version = ">= 1.5"
  backend "local" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "tf_state" {
  bucket        = "devops-prep-tf-state-${var.account_id}"
  force_destroy = true
}


resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration { status = "Enabled" }
}


resource "aws_dynamodb_table" "tf_locks" {
  name         = "devops-prep-tf-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

