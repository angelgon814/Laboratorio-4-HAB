## ElastiCache Memcached Subnet Group
#resource "aws_elasticache_subnet_group" "wordpress_memcached" {
#  name       = "wordpress-memcached-subnet"
#  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
#}

## ElastiCache Memcached Parameter Group
#resource "aws_elasticache_parameter_group" "wordpress_memcached" {
#  family = "memcached1.6"
#  name   = "wordpress-memcached-params"

#  parameter {
#    name  = "max_item_size"
#    value = "10485760" # 10MB
#  }
#}

## Security Group for Memcached
#resource "aws_security_group" "memcached" {
#  name        = "wordpress-memcached-sg"
#  description = "Security group for WordPress Memcached cluster"
#  vpc_id      = aws_vpc.main.id

#  ingress {
#    from_port       = 11211
#    to_port         = 11211
#    protocol        = "tcp"
#    security_groups = [aws_security_group.wordpress_ec2.id]
#  }

#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }

#  tags = {
#    Name = "wordpress-memcached-sg"
#  }
#}

## ElastiCache Memcached Cluster
#resource "aws_elasticache_cluster" "wordpress_memcached" {
#  cluster_id           = "wordpress-memcached"
#  engine              = "memcached"
#  node_type           = "cache.t3.micro"
#  num_cache_nodes     = 2
#  port                = 11211
#  
#  parameter_group_name = aws_elasticache_parameter_group.wordpress_memcached.name
#  subnet_group_name    = aws_elasticache_subnet_group.wordpress_memcached.name
#  security_group_ids   = [aws_security_group.memcached.id]

#  maintenance_window = "sun:05:00-sun:06:00"
#  
#  tags = {
#    Name        = "wordpress-memcached"
#    Environment = "Production"
#  }
#}
