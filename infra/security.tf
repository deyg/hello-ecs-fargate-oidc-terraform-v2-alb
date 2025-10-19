# SG DO VPC LINK (ASSOCIADO AOS ENIs DO API GATEWAY)
resource "aws_security_group" "vpclink" {
  name   = "sg-vpclink"
  vpc_id = module.vpc.vpc_id

  egress { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }
  tags = { Name = "sg-vpclink" }
}

# SG DO ALB (ACEITA TRÁFEGO DO SG DO VPC LINK NA PORTA 80)
resource "aws_security_group" "alb" {
  name   = "sg-alb"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    security_groups          = [aws_security_group.vpclink.id]
    description              = "Allow from VPC Link SG"
  }

  egress { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }
  tags = { Name = "sg-alb" }
}

# SG DO SERVIÇO ECS (ACEITA TRÁFEGO DO ALB NA PORTA 3000)
resource "aws_security_group" "svc" {
  name   = "sg-ecs-svc"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Allow from ALB"
  }

  egress { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }
  tags = { Name = "sg-ecs-svc" }
}
