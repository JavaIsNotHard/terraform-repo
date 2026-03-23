resource "aws_launch_template" "example" {
  name_prefix   = "example-"
  image_id      = "ami-0b6c6ebed2801a5cb"
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.example_sg.id]

  user_data = base64encode(<<-EOF
  #!/bin/bash
  echo "Hello, World" > index.html
  nohup busybox httpd -f -p ${var.server_port} &
  EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  // vpc_zone_identifier is used to tell your ASG to use the subnets in the VPC.
  // We filter out us-east-1e because it doesn't support t3.micro.
  vpc_zone_identifier = [for s in data.aws_subnet.default : s.id if s.availability_zone != "us-east-1e"]

  target_group_arns = [aws_alb_target_group.alb_target_group.arn]
  // The default health_check_type is "EC2", which is a minimal health check that considers an Instance unhealthy only if the AWS hypervisor says the VM is completely down or unreachable.
  // The "ELB" health check type instructs the ASG to use the target group’s health check to determine whether an Instance is healthy
  health_check_type = "ELB"
  min_size          = 2
  max_size          = 10

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

}
