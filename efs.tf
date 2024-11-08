# EFS
resource "aws_efs_file_system" "wordpress_efs" {
  creation_token = "wordpress-efs"
  encrypted      = true

  tags = {
    Name = "wordpress-efs"
    LAB4 = "HAB"
    Owner = "ANGEL"
  }
}

# Mount Targets del EFS
resource "aws_efs_mount_target" "private_1" {
  file_system_id  = aws_efs_file_system.wordpress_efs.id
  subnet_id       = aws_subnet.private_1.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "private_2" {
  file_system_id  = aws_efs_file_system.wordpress_efs.id
  subnet_id       = aws_subnet.private_2.id
  security_groups = [aws_security_group.efs.id]
}



