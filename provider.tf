terraform {
  backend "s3" {
    region = "eu-central-1"
    key    = "frontend-stack.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.38"

    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

provider "aws" {
  alias  = "region_use1"
  region = "us-east-1"
}
