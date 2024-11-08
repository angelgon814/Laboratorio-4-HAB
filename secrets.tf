
# Generar un ID aleatorio para los nombres de los secretos
#resource "random_id" "secrets_name" {
#  byte_length = 8
#}

# Secreto para el nombre de la base de datos
#resource "aws_secretsmanager_secret" "db_name" {
#  name        = "wordpress-db-name-${random_id.secrets_name.hex}"
#  description = "Nombre de la base de datos WordPress"
#}

#resource "aws_secretsmanager_secret_version" "db_name" {
#  secret_id     = aws_secretsmanager_secret.db_name.id
#  secret_string = "wordpress_db"
#}

# Secreto para el usuario de la base de datos
#resource "aws_secretsmanager_secret" "db_username" {
#  name        = "wordpress-db-username-${random_id.secrets_name.hex}"
#  description = "Usuario para la base de datos WordPress"
#}

#resource "aws_secretsmanager_secret_version" "db_username" {
#  secret_id     = aws_secretsmanager_secret.db_username.id
#  secret_string = "wordpressuser"
#}

# Secreto para la contraseña de la base de datos
#resource "aws_secretsmanager_secret" "db_password" {
#  name        = "wordpress-db-password-${random_id.secrets_name.hex}"
#  description = "Contraseña para la base de datos WordPress"
#}

#resource "aws_secretsmanager_secret_version" "db_password" {
#  secret_id     = aws_secretsmanager_secret.db_password.id
#  secret_string = "your_secure_password123!"
#}


# Política IAM para permitir a las instancias EC2 acceder a los secretos
#data "aws_iam_policy_document" "secrets_access" {
#  statement {
#    effect = "Allow"
#    actions = [
#      "secretsmanager:GetSecretValue",
#      "secretsmanager:DescribeSecret",
#      "secretsmanager:ListSecrets"
#    ]
#    resources = [
#      aws_secretsmanager_secret.db_name.arn,
#      aws_secretsmanager_secret.db_username.arn,
#      aws_secretsmanager_secret.db_password.arn
#    ]
#  }
#}
