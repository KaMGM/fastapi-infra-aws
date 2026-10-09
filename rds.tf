resource "aws_db_instance" "postgres" {
  identifier = "postgres-db"
  engine     = "postgres"
  engine_version = "15"
  instance_class = "db.t3.micro"
  
  allocated_storage = 20
  db_name           = "mydb"
  username          = "dbuser"
  password          = var.db_password # À gérer via secrets
  
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  skip_final_snapshot = true
  publicly_accessible = false

  tags = { Name = "RDS PostgreSQL" }
}

# Sous-réseau de base de données
resource "aws_db_subnet_group" "main" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.private.id,aws_subnet.private_b.id]
}

# SG pour RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "ALB - HTTP/HTTPS acces Internet"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }
}