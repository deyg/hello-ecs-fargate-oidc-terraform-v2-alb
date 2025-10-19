output "cluster_name" { value = aws_ecs_cluster.this.name }
output "ecr_repo"     { value = aws_ecr_repository.app.repository_url }
output "api_url"      { value = "${aws_apigatewayv2_api.api.api_endpoint}/hello" }
