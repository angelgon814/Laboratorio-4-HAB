
#resource "aws_db_subnet_group" "rds_subnet_group" {
#  name       = "rds-subnet-group"
#  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
#
#  tags = {
#    Name = "Grupo de subredes de RDS"
#  }
#}
#
## Instancia de RDS
#resource "aws_db_instance" "wordpress" {
#  identifier        = "wordpress-postgres"
#  engine           = "postgres"
#  engine_version   = "16.1"
#  instance_class   = "db.t3.micro"
#  
#  snapshot_identifier = "arn:aws:rds:us-east-1:676206907759:snapshot:wp-backup-rds"
#  
#  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
#  vpc_security_group_ids = [aws_security_group.rds.id]
#
#  multi_az            = true
#  publicly_accessible = false
#  skip_final_snapshot = true
#
#  
#  tags = {
#    Name = "PostgreSQL Database"
#  }
#
#  lifecycle {
#    ignore_changes = [
#      engine_version,
#      snapshot_identifier,
#      identifier_prefix,
#      maintenance_window,
#      backup_window,
#      backup_retention_period
#    ]
#  }
#}
