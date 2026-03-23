resource "aws_alb" "example_alb" {
  name               = "terraform-asg-example"
  load_balancer_type = "application"
  subnets            = [for s in data.aws_subnet.default : s.id if s.availability_zone != "us-east-1e"]
  security_groups    = [aws_security_group.alb_security_group.id]
}

resource "aws_alb_listener" "example_alb_listener" {
  load_balancer_arn = aws_alb.example_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_security_group" "alb_security_group" {
  name = "terraform-alb-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb_target_group" "alb_target_group" {
  name     = "terraform-target-group"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_alb_listener_rule" "alb_listener_rule" {
  listener_arn = aws_alb_listener.example_alb_listener.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_target_group.arn
  }

}

output "lb_dns_name" {
  value       = aws_alb.example_alb.dns_name
  description = "domain name for our ALB"
}
