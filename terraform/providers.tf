terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.00"
    }
  }

  backend "s3" {
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.dep_region
  profile = "mfa_cli"
}
