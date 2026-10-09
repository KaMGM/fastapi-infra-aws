# 1. Création du sujet SNS pour les alertes E-mail
resource "aws_sns_topic" "email_alerts" {
  name = "cloudwatch-email-alerts"
}

# 2. Abonnement de votre adresse E-mail au sujet SNS
resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.email_alerts.arn
  protocol  = "email"
  endpoint  = var.mail 
}

# 3. Alarme CloudWatch sur le taux d'erreurs  (Matrice d'erreurs)
resource "aws_cloudwatch_metric_alarm" "fastapi_5xx_errors" {
  alarm_name          = "fastapi-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Alerte : Plus de 5 erreurs HTTP 5xx detectees sur l'ALB en 1 minute."

  alarm_actions = [aws_sns_topic.email_alerts.arn] # Notification en cas d'erreur
  ok_actions    = [aws_sns_topic.email_alerts.arn] # Notification lors du retour a la normale
}

# 4. Alarme CloudWatch sur la latence du chemin critique
resource "aws_cloudwatch_metric_alarm" "fastapi_high_latency" {
  alarm_name          = "fastapi-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0.5 # 500 ms
  alarm_description   = "Alerte : Le temps de reponse moyen de FastAPI depasse 500ms sur le chemin critique."

  alarm_actions = [aws_sns_topic.email_alerts.arn]
}

#  SURVEILLANCE CPU & MÉMOIRE (ECS FARGATE)

# Alarme : Consommation CPU élevée sur le service Fargate
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "fargate-cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80 # Déclenchement si le CPU dépasse 80% pendant 2 minutes
  alarm_description   = "Alerte : La consommation CPU du service Fargate depasse 80%."

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.main.name
  }

  alarm_actions = [aws_sns_topic.email_alerts.arn]
  ok_actions    = [aws_sns_topic.email_alerts.arn]
}

# Alarme : Consommation Mémoire (RAM) élevée sur le service Fargate
resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  alarm_name          = "fargate-memory-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 85 # Déclenchement si la RAM dépasse 85% pendant 2 minutes
  alarm_description   = "Alerte : La consommation de mémoire RAM du service Fargate depasse 85%."

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.main.name
  }

  alarm_actions = [aws_sns_topic.email_alerts.arn]
  ok_actions    = [aws_sns_topic.email_alerts.arn]
}

# Alarme : Volume de stockage total du Bucket S3
resource "aws_cloudwatch_metric_alarm" "s3_bucket_size_high" {
  alarm_name          = "s3-bucket-size-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "BucketSizeBytes"
  namespace           = "AWS/S3"
  period              = 86400 # Vérification quotidienne 
  statistic           = "Average"
  threshold           = 53687091200 # 50 Go 

  dimensions = {
    BucketName  = "my-private-docs-dev" 
    StorageType = "StandardStorage"
  }

  alarm_actions = [aws_sns_topic.email_alerts.arn]
}

# Alarme : Nombre total d'objets (fichiers) stockés dans S3
resource "aws_cloudwatch_metric_alarm" "s3_number_of_objects_high" {
  alarm_name          = "s3-number-of-objects-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "NumberOfObjects"
  namespace           = "AWS/S3"
  period              = 86400 # 24 heures
  statistic           = "Average"
  threshold           = 10 # Déclenchement si le bucket dépasse 10 fichiers
  alarm_description   = "Alerte : Le nombre de documents stockés dans S3 a depasse 10."

  dimensions = {
    BucketName  = "my-private-docs-dev"
    StorageType = "AllStorageTypes"
  }

  alarm_actions = [aws_sns_topic.email_alerts.arn]
}