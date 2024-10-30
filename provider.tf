terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # version = "5.14.0"
    }
  }
}

provider "aws" {
  region                   = "eu-west-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "aai-admin"
  default_tags {
    tags = {
      useCase    = "tutorial"
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
      CostCenter  = var.cost_center
    }
  }
}
