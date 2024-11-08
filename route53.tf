# Crear zona privada
resource "aws_route53_zone" "private" {
  name = "internal.wordpress.local"

  vpc {
    vpc_id = aws_vpc.main.id
  }

  tags = {
    Name = "wordpress-private-zone"
    LAB4 = "HAB"
    OWNER = "ANGEL"
  }
}

# Crear DNS para RDS
resource "aws_route53_record" "rds" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "db.internal.wordpress.local"
  type    = "CNAME"
  ttl     = "300"
  records = [split(":", aws_db_instance.wordpress.endpoint)[0]]
}

# Crear DNS para EFS
resource "aws_route53_record" "efs" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "efs.internal.wordpress.local"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_efs_file_system.wordpress_efs.dns_name]
}

# Crear DNS para ElastiCache
resource "aws_route53_record" "elasticache" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "cache.internal.wordpress.local"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_elasticache_cluster.wordpress.cache_nodes[0].address]
}
# Crear DNS para ALB Externo
resource "aws_route53_record" "external_alb" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "external.internal.wordpress.local"
  type    = "A"

  alias {
    name                   = aws_lb.external.dns_name
    zone_id                = aws_lb.external.zone_id
    evaluate_target_health = true
  }
}
