resource "aws_lb" "this" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnets

  enable_deletion_protection = false

  tags = {
    Name = var.name
  }
}

resource "aws_lb_target_group" "this" {
  name     = "${var.name}-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id  // Add your VPC ID here

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold  = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group_arn = aws_lb_target_group.this.arn
    }
  }
}

resource "aws_lb_target_group_attachment" "this" {
  count              = length(var.target_instance_arns)
  target_group_arn   = aws_lb_target_group.this.arn
  target_id          = element(var.target_instance_arns, count.index)
  port               = 80  // Port on which the EC2 instance is listening
}
