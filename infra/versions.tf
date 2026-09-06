terraform {
  backend "s3" {
    bucket         = "terraform-standard-backend-20260223155131893200000001"
    key            = "ecs-terraform-lab/terraform.tfstate"
    dynamodb_table = "terraform-series-s3-backend"
    region         = "us-east-2"
    encrypt        = true 
    assume_role    ={
        role_arn       = "arn:aws:iam::186334912698:role/Terraform-SeriesS3BackendRole"
    }                         
  }
}

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state — PHẢI tạo S3 bucket + DynamoDB table này TRƯỚC khi terraform init.
  # Xem README.md phần "Bootstrap state backend". Bỏ comment và điền tên thật:
  #
  # backend "s3" {
  #   bucket         = "your-tfstate-bucket-name"
  #   key            = "ecs-terraform-lab/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
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
