terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {
    bucket         = "tfstate-7t-demo"
    key            = "ecs-hello-v2/infra.tfstate"
    region         = "sa-east-1"
    dynamodb_table = "tf-locks-7t-demo"
    encrypt        = true
  }
}

provider "aws" { region = var.aws_region }
