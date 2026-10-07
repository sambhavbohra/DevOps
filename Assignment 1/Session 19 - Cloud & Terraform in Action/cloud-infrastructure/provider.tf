terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Cloud-Terraform-Action"
      Environment = var.environment
      Owner       = "Sambhav D Bohra"
      RegNumber   = "24bcs10090"
      ManagedBy   = "Terraform"
    }
  }
}
