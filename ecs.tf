# 1. Création du groupe de logs CloudWatch
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/fastapi-app"
  retention_in_days = 7
}

resource "aws_ecs_cluster" "main" {
  name = "my-fargate-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Task Definition (Simplifiée pour l'exemple)
resource "aws_ecs_task_definition" "app" {
  family                = "fastapi-app"
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                   = var.cpu
  memory                = var.memory

  #cpu                   = 256
  #memory                = 512
  
  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name  = "fastapi"
    image = "${aws_ecr_repository.main.repository_url}:latest"
    portMappings = [{ containerPort = 8000 }]
  }])
}

# ECR pour stocker les images
resource "aws_ecr_repository" "main" {
  name = "fastapi-app"
  force_delete = true
}

resource "aws_ecs_service" "main" {
  name            = "fastapi-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "fastapi" 
    container_port   = 8000      
  }

  network_configuration {
    subnets          = [aws_subnet.public.id, aws_subnet.public_b.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true  # Subnet public
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_execution_role_policy]
}