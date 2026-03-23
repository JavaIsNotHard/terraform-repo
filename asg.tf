resource "aws_launch_configuration" "example" {
  image_id        = "ami-0b6c6ebed2801a5cb"
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.example_sg]

  user_data = <<-EOF
  #!/bin/bash
  echo "Hello, World" > index.html
  nohup busybox httpd -f -p ${var.server_port} &
  EOF

  // this ensures that a new launch configuration is created before deleting the old one
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = data.aws_subnets.default.ids
  min_size             = 2
  max_size             = 10

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

}
