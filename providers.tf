terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.9"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = var.region
  profile = var.aws-profile
}
