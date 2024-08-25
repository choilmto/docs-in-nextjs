terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.51.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-backend-nextjs-app-2024"
    key            = "state/terraform-ecr.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }

  required_version = "~> 1.9.0"
}

provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = {
      environment = "Prod"
      app         = "Blog"
    }
  }
}

resource "aws_ecr_repository" "artifacts" {
  name                 = "blog-artifacts"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
