# Launch Template
resource "aws_launch_template" "wordpress" {
  name_prefix   = "wordpress-template"
  image_id      = "ami-088be0419c9759df9"  # Amazon Linux 2023
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [aws_security_group.wordpress_ec2.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(<<-EOF
#!/bin/bash

# Actualizar el sistema
sudo dnf update -y

#!/bin/bash

# Actualizar el sistema
sudo dnf update -y

# Montar EFS en /mnt/efs/fs1
sudo mkdir -p /mnt/efs/fs1
sudo mount -t efs ${aws_efs_file_system.wordpress_efs.id}:/ /mnt/efs/fs1
echo "${aws_efs_file_system.wordpress_efs.id}:/ /mnt/efs/fs1 efs defaults,_netdev 0 0" | sudo tee -a /etc/fstab
sudo mount -a

# Verificar si la carpeta WordPress ya existe en EFS
if [ -d "/mnt/efs/fs1/wordpress" ]; then
    echo "EFS ya contiene la carpeta wordpress. Sincronizando contenido..."

    # Borrar cualquier contenido existente en /var/www/html de la instancia
    sudo rm -rf /var/www/html/*

    # Sincronizar contenido del EFS al directorio local /var/www/html
    sudo rsync -a --delete /mnt/efs/fs1/wordpress/ /var/www/html/
else
    echo "EFS no contiene la carpeta wordpress. Inicializando contenido..."

    # Crear carpeta wordpress en EFS
    sudo mkdir -p /mnt/efs/fs1/wordpress

    # Mover contenido local al EFS
    sudo mv /var/www/html/* /mnt/efs/fs1/wordpress/

    # Sincronizar contenido del EFS al directorio local /var/www/html
    sudo rsync -a /mnt/efs/fs1/wordpress/ /var/www/html/
fi

# Establecer permisos para Apache en /var/www/html
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html

# Reiniciar y habilitar Apache
sudo systemctl restart httpd
sudo systemctl enable httpd


# Variables de entorno
ALB_DNS="https://${aws_lb.external.dns_name}"
DB_NAME="${aws_db_instance.wordpress.db_name}"
DB_USER="${aws_db_instance.wordpress.username}"
DB_PASSWORD="${aws_db_instance.wordpress.password}"
DB_HOST="db.internal.wordpress.local"

# Esperar a que wp-config.php esté disponible
while [ ! -f /var/www/html/wp-config.php ]; do
    echo "Esperando a que wp-config.php esté disponible..."
    sleep 5
done

# Cambios en wp-config.php
sudo sed -i "s/define( *'DB_NAME'.*/define('DB_NAME', '$DB_NAME');/" /var/www/html/wp-config.php
sudo sed -i "s/define( *'DB_USER'.*/define('DB_USER', '$DB_USER');/" /var/www/html/wp-config.php
sudo sed -i "s/define( *'DB_PASSWORD'.*/define('DB_PASSWORD', '$DB_PASSWORD');/" /var/www/html/wp-config.php
sudo sed -i "s/define( *'DB_HOST'.*/define('DB_HOST', '$DB_HOST');/" /var/www/html/wp-config.php
sudo sed -i "s|define( *'WP_HOME'.*|define('WP_HOME', '$ALB_DNS');|" /var/www/html/wp-config.php
sudo sed -i "s|define( *'WP_SITEURL'.*|define('WP_SITEURL', '$ALB_DNS');|" /var/www/html/wp-config.php

# Instala wp-cli si no está instalado
if ! command -v wp &> /dev/null; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    sudo chmod +x wp-cli.phar
    sudo mv wp-cli.phar /usr/local/bin/wp
fi

# Install WordPress si no está instalado
cd /var/www/html
if ! sudo -u apache wp core is-installed --path=/var/www/html/; then
    sudo -u apache wp core install \
        --url="$ALB_DNS" \
        --title="Laboratorio 4 de Angel" \
        --admin_user=admin \
        --admin_password=12345678 \
        --admin_email=angelgon814@gmail.com \
        --path=/var/www/html/
fi

# Activar Redis Object Cache en WordPress
cd /var/www/html

# Esperar a que el archivo wp-config.php exista
while [ ! -f /var/www/html/wp-config.php ]; do
    echo "Esperando a que wp-config.php esté disponible..."
    sleep 5
done

# Verificar si el plugin Redis Object Cache ya está activo
if ! sudo -u apache wp plugin is-active redis-cache --path=/var/www/html/; then
    echo "Activando el plugin Redis Object Cache..."
    sudo -u apache wp plugin activate redis-cache --path=/var/www/html/
else
    echo "El plugin Redis Object Cache ya está activo."
fi

# Verificar si Redis Object Cache ya está habilitado
if ! sudo -u apache wp redis status --path=/var/www/html/ | grep -q "Status: Connected"; then
    echo "Habilitando Redis Object Cache..."
    sudo -u apache wp redis enable --path=/var/www/html/
else
    echo "Redis Object Cache ya está habilitado y conectado."
fi

# Restart Apache
sudo systemctl restart httpd

sudo echo "OK" > /var/www/html/health

EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "wordpress-instance"
      LAB4 = "HAB"
      Owner = "ANGEL"
    }
  }
  depends_on = [
    aws_db_instance.wordpress,
    aws_efs_file_system.wordpress_efs,
    aws_elasticache_cluster.wordpress
  ]
}

# Auto Scaling Group
resource "aws_autoscaling_group" "wordpress" {
  name                = "wordpress-asg"
  desired_capacity    = 2
  max_size            = 3
  min_size            = 2
  target_group_arns   = [aws_lb_target_group.wordpress_external.arn,aws_lb_target_group.wordpress_internal.arn]
  vpc_zone_identifier = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  launch_template {
    id      = aws_launch_template.wordpress.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "wordpress-asg-instance"
    propagate_at_launch = true
  }
}


