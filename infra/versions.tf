terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-standard-backend-20260223155131893200000001"
    key            = "ecs-terraform-lab/terraform.tfstate"
    dynamodb_table = "terraform-series-s3-backend"
    region         = "us-east-2"
    encrypt        = true

    assume_role    = {
      role_arn = "arn:aws:iam::186334912698:role/Terraform-SeriesS3BackendRole"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "terraform"
    }
  }
}