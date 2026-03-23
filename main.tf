provider "aws" {
  region = "us-east-1"
}

variable "server_port" {
  description = "The port the server will use to serve HTTP request"
  type        = number
  default     = 8080
}

output "public_ip" {
  value       = aws_instance.example.public_ip
  description = "The public IP address of the web sever"
}

resource "aws_instance" "example" {
  ami                    = "ami-0b6c6ebed2801a5cb"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.example_sg.id]

  user_data = <<-EOF
              #!/bin/sh
              echo "Hello World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  // the user_data_replace_on_change option is set to true so that when you change the user_data parameter and run apply, terraform will terminate the origin instance and launch a new one
  user_data_replace_on_change = true

  tags = {
    Name = "terraform-example"
  }
}

resource "aws_security_group" "example_sg" {
  name = "example_security_group"

  // from_port: The start of the range of ports you want to open.
  // to_port: The end of the range of ports you want to open.
  ingress {
    to_port     = var.server_port
    from_port   = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpcs" "all" {}

output "vpc_ids" {
  value = data.aws_vpcs.all.ids
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "default" {
  for_each = toset(data.aws_subnets.default.ids)
  id       = each.value
}

output "subnet_ids" {
  value       = data.aws_subnets.default.ids
  description = "The IDs of the subnets in the default VPC"
}
