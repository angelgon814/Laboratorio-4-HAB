# Backup VPC
resource "aws_vpc" "backup" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "wordpress-backup-vpc"
  }
}

# Subnet Privada en Backup VPC
resource "aws_subnet" "backup_private" {
  vpc_id            = aws_vpc.backup.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "wordpress-backup-private"
  }
}

# Conexión VPC Peering
resource "aws_vpc_peering_connection" "main_to_backup" {
  peer_vpc_id = aws_vpc.backup.id
  vpc_id      = aws_vpc.main.id
  auto_accept = true

  tags = {
    Name = "wordpress-vpc-peering"
  }
}

# Tabla de rutas para Backup VPC
resource "aws_route_table" "backup" {
  vpc_id = aws_vpc.backup.id

  route {
    cidr_block                = aws_vpc.main.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.main_to_backup.id
  }

  tags = {
    Name = "wordpress-backup-rt"
  }
}

# Asociación de tabla de rutas para Subnet Backup
resource "aws_route_table_association" "backup" {
  subnet_id      = aws_subnet.backup_private.id
  route_table_id = aws_route_table.backup.id
}

# Añadir ruta a tablas de rutas de VPC principal para Backup VPC
resource "aws_route" "main_to_backup_private1" {
  route_table_id            = aws_route_table.private_1.id
  destination_cidr_block    = aws_vpc.backup.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main_to_backup.id
}

resource "aws_route" "main_to_backup_private2" {
  route_table_id            = aws_route_table.private_2.id
  destination_cidr_block    = aws_vpc.backup.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main_to_backup.id
}

# Bucket S3 para backups
resource "aws_s3_bucket" "wordpress_backup" {
  bucket = "wordpress-backup-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "wordpress-backup"
  }
}

# Habilitar versionado para bucket de backups
resource "aws_s3_bucket_versioning" "wordpress_backup" {
  bucket = aws_s3_bucket.wordpress_backup.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Habilitar encriptación para bucket de backups
resource "aws_s3_bucket_server_side_encryption_configuration" "wordpress_backup" {
  bucket = aws_s3_bucket.wordpress_backup.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloquear acceso público para bucket de backups
resource "aws_s3_bucket_public_access_block" "wordpress_backup" {
  bucket = aws_s3_bucket.wordpress_backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
