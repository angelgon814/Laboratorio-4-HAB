# Importar certificado SSL a ACM
resource "aws_acm_certificate" "imported_wp" {
  certificate_body = file("${path.module}/certificates/certificate.pem")
  private_key      = file("${path.module}/certificates/private.pem")


  tags = {
    Name     = "wordpress-certificate"
    proyecto = "lab4"
    id       = "angel"
  }
}