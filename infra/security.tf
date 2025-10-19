# SG do VPC Link (associado aos ENIs do API Gateway)
resource "aws_security_group" "vpclink" {
  name   = "vpclink"
  vpc_id = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "sg-vpclink" }
}

# SG do ALB (aceita trafego do SG do VPC Link na porta 80)
resource "aws_security_group" "alb" {
  name   = "alb-internal"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.vpclink.id]
    description     = "Allow from VPC Link SG"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "sg-alb" }
}

# SG do servico ECS (aceita trafego do ALB na porta 3000)
resource "aws_security_group" "svc" {
  name   = "ecs-service"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Allow from ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "sg-ecs-svc" }
}
