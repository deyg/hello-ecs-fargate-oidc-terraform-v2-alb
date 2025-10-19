module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "hello-vpc"
  cidr = "10.10.0.0/16"

  azs             = ["sa-east-1a", "sa-east-1c"]
  public_subnets  = ["10.10.101.0/24", "10.10.102.0/24"]
  private_subnets = ["10.10.1.0/24",   "10.10.2.0/24"]

  enable_nat_gateway = true

  tags = { Project = "hello-ecs-alb" }
}
