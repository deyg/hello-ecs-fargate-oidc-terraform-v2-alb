resource "aws_ecr_repository" "app" {
  name = "hello-ecs"
  image_scanning_configuration { scan_on_push = true }
  force_delete = true
}
