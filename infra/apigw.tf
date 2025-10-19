# HTTP API PÚBLICO CHAMANDO SERVIÇO PRIVADO VIA VPC LINK
resource "aws_apigatewayv2_api" "api" {
  name          = "hello-http-api"
  protocol_type = "HTTP"
}

# VPC LINK COM SUB-REDE PRIVADA E SG PRÓPRIO
resource "aws_apigatewayv2_vpc_link" "link" {
  name               = "hello-vpclink"
  subnet_ids         = module.vpc.private_subnets
  security_group_ids = [aws_security_group.vpclink.id]
}

resource "aws_apigatewayv2_integration" "int" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "HTTP_PROXY"
  connection_type        = "VPC_LINK"
  connection_id          = aws_apigatewayv2_vpc_link.link.id
  integration_method     = "ANY"
  # PARA ALB PRIVADO + HTTP API + VPC LINK, USE O ARN DO LISTENER HTTP:
  integration_uri        = aws_lb_listener.http.arn
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "hello" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.int.id}"
}

resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "prod"
  auto_deploy = true
}

output "invoke_url" {
  value = "${aws_apigatewayv2_api.api.api_endpoint}/hello"
}
