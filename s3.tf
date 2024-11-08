# Cadena aleatoria para nombres de bucket únicos
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
  lower   = true
  numeric = true
}

# Bucket de S3 para archivos multimedia de WordPress
resource "aws_s3_bucket" "wordpress_media" {
  bucket = lower("wp-media-${data.aws_caller_identity.current.account_id}-${random_string.suffix.result}")

  tags = {
    Name = "wordpress-media"
  }
}

# Habilitar versionamiento para el bucket de multimedia de WordPress
resource "aws_s3_bucket_versioning" "wordpress_media" {
  bucket = aws_s3_bucket.wordpress_media.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Bloquear acceso público para el bucket de multimedia de WordPress
resource "aws_s3_bucket_public_access_block" "wordpress_media" {
  bucket = aws_s3_bucket.wordpress_media.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Tabla de DynamoDB para sesiones de WordPress
resource "aws_dynamodb_table" "wordpress_sessions" {
  name           = "wordpress-sessions"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "sid"
  stream_enabled = false

  attribute {
    name = "sid"
    type = "S"
  }

  ttl {
    attribute_name = "expires"
    enabled        = true
  }

  tags = {
    Name = "wordpress-sessions"
    LAB4 = "HAB"
    OWNER = "ANGEL"
  }
}
