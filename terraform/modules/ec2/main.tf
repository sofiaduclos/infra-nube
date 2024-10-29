resource "tls_private_key" "key_gen" {  
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  filename = "${path.module}/api-instance.pem"
  content  = tls_private_key.key_gen.private_key_openssh
}

resource "aws_key_pair" "key" {  
  key_name   = "api-instance-key"
  public_key = tls_private_key.key_gen.public_key_openssh
}


resource "aws_launch_template" "api_instance" {
  name_prefix   = "api-instance"
  image_id      = var.ami_id
  instance_type = var.instance_type  # Use a variable for instance type
  key_name      = aws_key_pair.key.key_name
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
      volume_type = "gp2"
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = var.subnet_id
    security_groups      = [var.security_group_id]
  }
}

