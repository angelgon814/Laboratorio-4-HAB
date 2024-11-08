# # Distribución de CloudFront
# resource "aws_cloudfront_distribution" "wordpress" {
#   enabled             = true
#   is_ipv6_enabled    = true
#   comment            = "WordPress CDN"
#   price_class        = "PriceClass_100"
#   wait_for_deployment = false

#   # Origen de ALB para la aplicación de WordPress
#   origin {
#     domain_name = aws_lb.external.dns_name
#     origin_id   = "ALB-WordPress"

#     custom_origin_config {
#       http_port              = 80
#       https_port             = 443
#       origin_protocol_policy = "https-only"
#       origin_ssl_protocols   = ["TLSv1.2"]
#     }
#   }

#   # Origen de S3 para archivos multimedia
#   origin {
#     domain_name = aws_s3_bucket.wordpress_media.bucket_regional_domain_name
#     origin_id   = "S3-${aws_s3_bucket.wordpress_media.id}"

#     custom_origin_config {
#       http_port              = 80
#       https_port             = 443
#       origin_protocol_policy = "http-only"
#       origin_ssl_protocols   = ["TLSv1.2"]
#     }
#   }

#   # Comportamiento de caché predeterminado para la aplicación de WordPress
#   default_cache_behavior {
#     allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = "ALB-WordPress"

#     forwarded_values {
#       query_string = true
#       cookies {
#         forward = "all"
#       }
#       headers = ["Host", "Origin"]
#     }

#     viewer_protocol_policy = "redirect-to-https"
#     min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
#   }

#   # Comportamiento de caché para archivos multimedia
#   ordered_cache_behavior {
#     path_pattern     = "/wp-content/uploads/*"
#     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = "S3-${aws_s3_bucket.wordpress_media.id}"

#     forwarded_values {
#       query_string = false
#       cookies {
#         forward = "none"
#       }
#     }

#     viewer_protocol_policy = "redirect-to-https"
#     min_ttl                = 0
#     default_ttl            = 86400
#     max_ttl                = 31536000
#     compress               = true
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   viewer_certificate {
#     cloudfront_default_certificate = true
#   }

#   tags = {
#     Name        = "wordpress-cdn"
#     Environment = "Production"
#   }
# }
