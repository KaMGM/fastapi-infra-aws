# Rôle ECS Execution
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

# Rôle ECS Task (Application)
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

# Politique pour lire S3 Privé
resource "aws_iam_role_policy" "s3_read_policy" {
  name = "s3-read-policy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      Resource = [
        aws_s3_bucket.private_docs.arn,
        "${aws_s3_bucket.private_docs.arn}/*"
      ]
    }]
  })
}

# Attachement de la politique d'exécution ECR / CloudWatch obligatoire pour Fargate
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# 1. Définition de la politique de lecture S3
resource "aws_iam_policy" "s3_read_policy" {
  name        = "s3-read-docs-dev-policy"
  description = "Autorise la lecture du bucket my-private-docs-dev depuis ECS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::my-private-docs-dev",
          "arn:aws:s3:::my-private-docs-dev/*"
        ]
      }
    ]
  })
}

# 2. Association de la politique au Task Role de votre tâche ECS
resource "aws_iam_role_policy_attachment" "attach_s3_read" {
  role       = aws_iam_role.ecs_task_role.name # Nom de votre ressource Task Role
  policy_arn = aws_iam_policy.s3_read_policy.arn
}