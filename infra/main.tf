terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {
    bucket         = "deyg-hello-ecs-oidc-tfstate"
    key            = "ecs-hello-v2/infra.tfstate"
    region         = "sa-east-1"
    dynamodb_table = "deyg-hello-ecs-oidc-tf-locks"
    encrypt        = true
  }
}

provider "aws" { region = var.aws_region }
