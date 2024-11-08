# Security Group para las instancias EC2
resource "aws_security_group" "wordpress_ec2" {
  name        = "wordpress-ec2-sg"
  description = "Security group para instancias EC2 de WordPress"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP desde ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_external.id]
  }

  ingress {
    description     = "HTTPS desde ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_external.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Añadir regla para DNS
  egress {
    description = "DNS"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  tags = {
    Name = "wordpress-ec2-sg"
    LAB4 = "HAB"
    OWNER = "ANGEL"
  }
}

# Security group para RDS
resource "aws_security_group" "rds" {
  name        = "wordpress-rds-sg"
  description = "Security group para instancia RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL desde instancias EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.wordpress_ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wordpress-rds-sg"
    LAB4 = "HAB"
    OWNER = "ANGEL"
  }
}

# Security group para ElastiCache Redis
resource "aws_security_group" "elasticache" {
  name        = "wordpress-elasticache-sg"
  description = "Security group para WordPress ElastiCache Redis"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Redis desde instancias EC2"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.wordpress_ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wordpress-elasticache-sg"
    LAB4 = "HAB"
    OWNER = "ANGEL"
  }
}

# Security group para ALB Externo
resource "aws_security_group" "alb" {
  name        = "wordpress-alb-sg"
  description = "Security group para ALB externo"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wordpress-alb-sg"
    LAB4 = "HAB"
    OWNER = "ANGEL"
  }
}


# Security group para EFS
resource "aws_security_group" "efs" {
  name        = "wordpress-efs-sg"
  description = "Security group for EFS mount targets"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "NFS from EC2"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.wordpress_ec2.id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wordpress-efs-sg"
    LAB4 = "HAB"
    OWNER = "ANGEL"
  }
}


# Security Group para ALB Externo
resource "aws_security_group" "alb_external" {
  name        = "wordpress-alb-external-sg"
  description = "Security group for external ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wordpress-alb-external-sg"
    LAB4 = "HAB"
    OWNER = "ANGEL"
  }
}

# Security Group para ALB Interno
resource "aws_security_group" "alb_internal" {
  name        = "wordpress-alb-internal-sg"
  description = "Security group for internal ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_external.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wordpress-alb-internal-sg"
  }
}
