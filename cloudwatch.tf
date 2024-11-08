# CloudWatch Dashboard para monitoreo integral
resource "aws_cloudwatch_dashboard" "wordpress_dashboard" {
  dashboard_name = "WordPress-Monitoring-Dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # EC2 Metrics
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", aws_autoscaling_group.wordpress.name],
            [".", "NetworkIn", ".", "."],
            [".", "NetworkOut", ".", "."],
            [".", "DiskReadBytes", ".", "."],
            [".", "DiskWriteBytes", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "EC2 Metrics"
        }
      },
      # RDS Metrics
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", aws_db_instance.wordpress.id],
            [".", "FreeStorageSpace", ".", "."],
            [".", "ReadIOPS", ".", "."],
            [".", "WriteIOPS", ".", "."],
            [".", "DatabaseConnections", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "RDS Metrics"
        }
      },
      # ElastiCache Redis Metrics
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ElastiCache", "CPUUtilization", "CacheClusterId", aws_elasticache_cluster.wordpress.id],
            [".", "FreeableMemory", ".", "."],
            [".", "NetworkBytesIn", ".", "."],
            [".", "NetworkBytesOut", ".", "."],
            [".", "CacheHits", ".", "."],
            [".", "CacheMisses", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "ElastiCache Metrics"
        }
      },
      # ALB Metrics
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.external.arn_suffix],
            [".", "TargetResponseTime", ".", "."],
            [".", "HTTPCode_Target_2XX_Count", ".", "."],
            [".", "HTTPCode_Target_4XX_Count", ".", "."],
            [".", "HTTPCode_Target_5XX_Count", ".", "."]
          ]
          period = 300
          stat   = "Sum"
          region = data.aws_region.current.name
          title  = "ALB Metrics"
        }
      },
      # EFS Metrics
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EFS", "TotalIOBytes", "FileSystemId", aws_efs_file_system.wordpress_efs.id],
            [".", "PermittedThroughput", ".", "."],
            [".", "StorageBytes", ".", "."],
            [".", "ClientConnections", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "EFS Metrics"
        }
      }
    ]
  })
}




# Grupo de logs de CloudWatch
resource "aws_cloudwatch_log_group" "wordpress" {
  name              = "/aws/wordpress"
  retention_in_days = 30

  tags = {
    Name = "wordpress-logs"
    LAB4 = "HAB"
    OWNER = "ANGEL"
  }
}

# Alarmas de CloudWatch para EC2
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "wordpress-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Esta métrica monitorea la utilización de CPU de la instancia EC2"
}

# Alarmas de CloudWatch para RDS
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "wordpress-rds-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "La utilización de CPU de RDS es demasiado alta"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.wordpress.id
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  alarm_name          = "wordpress-rds-low-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "5000000000" # 5GB en bytes
  alarm_description   = "El espacio de almacenamiento libre de RDS es demasiado bajo"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.wordpress.id
  }
}

# Alarmas de CloudWatch para ElastiCache
resource "aws_cloudwatch_metric_alarm" "elasticache_cpu" {
  alarm_name          = "wordpress-elasticache-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "La utilización de CPU de ElastiCache es demasiado alta"
  dimensions = {
    CacheClusterId = aws_elasticache_cluster.wordpress.id
  }
}

resource "aws_cloudwatch_metric_alarm" "elasticache_memory" {
  alarm_name          = "wordpress-elasticache-low-memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/ElastiCache"
  period              = "300"
  statistic           = "Average"
  threshold           = "100000000" # 100MB en bytes
  alarm_description   = "La memoria libre de ElastiCache es demasiado baja"
  dimensions = {
    CacheClusterId = aws_elasticache_cluster.wordpress.id
  }
}

# Alarmas de CloudWatch para EFS
resource "aws_cloudwatch_metric_alarm" "efs_storage" {
  alarm_name          = "wordpress-efs-low-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "BurstCreditBalance"
  namespace           = "AWS/EFS"
  period              = "300"
  statistic           = "Average"
  threshold           = "100000000000" # 100GB en bytes
  alarm_description   = "El balance de créditos de EFS es demasiado bajo"
  dimensions = {
    FileSystemId = aws_efs_file_system.wordpress_efs.id
  }
}

resource "aws_cloudwatch_metric_alarm" "efs_throughput" {
  alarm_name          = "wordpress-efs-high-throughput"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "PercentIOLimit"
  namespace           = "AWS/EFS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "EFS IO limit utilization is too high"
  dimensions = {
    FileSystemId = aws_efs_file_system.wordpress_efs.id
  }
}
