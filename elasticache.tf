# Grupo de subredes ElastiCache
resource "aws_elasticache_subnet_group" "wordpress" {
  name       = "wordpress-cache-subnet"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

# Grupo de parámetros ElastiCache
resource "aws_elasticache_parameter_group" "wordpress" {
  family = "redis7"
  name   = "wordpress-cache-params"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }
}

# ElastiCache Redis cluster
resource "aws_elasticache_cluster" "wordpress" {
  cluster_id           = "wordpress-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = aws_elasticache_parameter_group.wordpress.name
  port                 = 6379
  security_group_ids   = [aws_security_group.elasticache.id]
  subnet_group_name    = aws_elasticache_subnet_group.wordpress.name
  engine_version       = "7.0"

  apply_immediately = false

  maintenance_window = "mon:05:00-mon:06:00"
  snapshot_window    = "03:00-04:00"

  tags = {
    Name = "wordpress-redis"
    LAB4 = "HAB"
    OWNER = "ANGEL"
  }

  lifecycle {
    # Comentamos temporalmente prevent_destroy
    # prevent_destroy = true
    ignore_changes = [
      engine_version,
      snapshot_window,
      maintenance_window,
      parameter_group_name,
      security_group_ids,
      snapshot_retention_limit
    ]
  }
}
