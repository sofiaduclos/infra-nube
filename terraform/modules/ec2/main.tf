resource "aws_launch_template" "api_instance" {
  name_prefix   = "api-instance"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

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
  }
}

resource "aws_autoscaling_group" "api_asg" {
  launch_template {
    id      = aws_launch_template.api_instance.id
    version = "$Latest"
  }

  vpc_zone_identifier = [var.subnet_id]
  min_size            = 1
  max_size            = 5  # Para escalar según la demanda
  desired_capacity    = 1
}
