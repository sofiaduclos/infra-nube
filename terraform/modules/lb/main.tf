resource "aws_lb" "lb" {
  name               = var.name
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnet

  tags = {
    Name = var.name
  }
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.target_group_arn  # Reference the target group
  }
}