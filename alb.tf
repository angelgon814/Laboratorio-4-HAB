# ALB Externo
resource "aws_lb" "external" {
  name               = "wordpress-external-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_external.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  tags = {
    Name = "wordpress-external-alb"
  }
}

# ALB Externo Target Group
resource "aws_lb_target_group" "wordpress_external" {
  name     = "wordpress-external-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

# Listener HTTPS para el ALB Externo
resource "aws_lb_listener" "external_https" {
  load_balancer_arn = aws_lb.external.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"         # Política de seguridad SSL recomendada
  certificate_arn   = aws_acm_certificate.imported_wp.arn # ARN del certificado importado en IAM

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_external.arn
  }
}

# Listener HTTP para redirigir tráfico a HTTPS
resource "aws_lb_listener" "external_http" {
  load_balancer_arn = aws_lb.external.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301" # Redirección permanente
    }
  }
}

# ALB Interno
resource "aws_lb" "internal" {
  name               = "wordpress-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_internal.id]
  subnets            = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "wordpress-internal-alb"
  }
}

# ALB Interno Target Group
resource "aws_lb_target_group" "wordpress_internal" {
  name     = "wordpress-internal-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

# Listener HTTP para el ALB Interno
resource "aws_lb_listener" "internal_http" {
  load_balancer_arn = aws_lb.internal.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_internal.arn
  }
}





