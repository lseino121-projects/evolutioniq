terraform {
  required_version = ">= 1.5.7"
  backend "s3" {
    bucket         = "devops-prep-tf-state-971146591534"
    dynamodb_table = "devops-prep-tf-locks"
    key            = "envs/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.15.0"
    }
  }
}

provider "aws" {
  region = var.region
}
