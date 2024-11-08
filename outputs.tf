# Endpoint de RDS
output "db_endpoint" {
  description = "Endpoint de la base de datos de RDS"
  value       = aws_db_instance.wordpress.endpoint
}

# DNS de EFS
output "efs_dns_name" {
  description = "DNS del sistema de archivos de EFS"
  value       = aws_efs_file_system.wordpress_efs.dns_name
}

# Endpoint de Redis
output "redis_endpoint" {
  description = "Endpoint del clúster de Redis"
  value       = aws_elasticache_cluster.wordpress.cache_nodes[0].address
}

# Bucket de Media de WordPress
output "wordpress_media_bucket" {
  value = aws_s3_bucket.wordpress_media.id
}

# DNS de ALB Externo
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.external.dns_name
}

# DNS interno de RDS
output "rds_dns_internal" {
  description = "Internal DNS name for RDS"
  value       = "db.internal.wordpress.local"
}

# Salida del dominio de la distribución de CloudFront
#output "cloudfront_domain_name" {
#  value = aws_cloudfront_distribution.wordpress.domain_name
#}





