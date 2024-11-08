# EC2 Rol
resource "aws_iam_role" "ec2_role" {
  name = "wordpress-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "wordpress-ec2-role"
    LAB4 = "HAB"
    OWNER = "ANGEL"
  }
}

# Perfil de instancia EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "wordpress-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# S3 Access Policy
resource "aws_iam_role_policy" "s3_access" {
  name = "wordpress-s3-access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.wordpress_media.arn,
          "${aws_s3_bucket.wordpress_media.arn}/*"
        ]
      }
    ]
  })
}

# Política de acceso a Systems Manager
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Política de acceso a CloudWatch
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Política de acceso a DynamoDB para la gestión de sesiones
resource "aws_iam_role_policy" "dynamodb_access" {
  name = "wordpress-dynamodb-access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [aws_dynamodb_table.wordpress_sessions.arn]
      }
    ]
  })
}

# Política de acceso a EFS
resource "aws_iam_role_policy" "efs_access" {
  name = "wordpress-efs-access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ]
        Resource = [aws_efs_file_system.wordpress_efs.arn]
      }
    ]
  })
}

# Política de acceso a ElastiCache
resource "aws_iam_role_policy" "elasticache_access" {
  name = "wordpress-elasticache-access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticache:DescribeCacheClusters",
          "elasticache:ListTagsForResource"
        ]
        Resource = [aws_elasticache_cluster.wordpress.arn]
      }
    ]
  })
}

resource "aws_iam_role_policy" "wordpress_secrets_kms_access" {
  name = "wordpress-secrets-kms-access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Permisos para acceder a los secretos de AWS Secrets Manager
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets"
        ]
        Resource = [
          "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:wordpress/*"
        ]
      },
      # Permisos para usar claves KMS para descifrar secretos
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}

# Política de acceso a Route53
resource "aws_iam_role_policy" "route53_access" {
  name = "wordpress-route53-access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:GetHostedZone",
          "route53:ListResourceRecordSets"
        ]
        Resource = "*"
      }
    ]
  })
}

# Rol de monitoreo de RDS
resource "aws_iam_role" "rds_monitoring" {
  name = "wordpress-rds-monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
