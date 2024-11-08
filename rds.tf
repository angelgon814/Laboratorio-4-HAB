resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "Grupo de subredes de RDS"
  }
}

#instancia de RDS
resource "aws_db_instance" "wordpress" {
  identifier        = "wordpress-postgres"
  engine            = "postgres"
  engine_version    = "16.1"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2" #


  db_name  = "wordpress_db"
  username = "wordpress_user"
  password = "your_secure_password123!" # Recuerda cambiar esto en producción

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az            = true
  publicly_accessible = false
  skip_final_snapshot = true

  tags = {
    Name = "Base de datos de PostgreSQL"
    LAB4 = "HAB"
    OWNER = "ANGEL"
  }

  lifecycle {
    # Comentamos temporalmente prevent_destroy
    # prevent_destroy = true
    ignore_changes = [
      engine_version,
      password,
      snapshot_identifier,
      identifier_prefix,
      maintenance_window,
      backup_window,
      backup_retention_period
    ]
  }
}
