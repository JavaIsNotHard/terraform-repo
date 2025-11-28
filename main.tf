provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "example" {
  ami = "ami-0fa3fe0fa7920f68e"
  instance_type = "t3.micro"

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  user_data_replace_on_change = true // terraform will terminate the original instance and launch a totally new one so that it can execute the script in user_data

  tags = {
    Name = "example-ec2"
  }
}

resource "aws_security_group" "instance" {
  name = "terraform_example_instance"

  ingress {
    // from and to port # defines the range of port that are allowed
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    // allow traffic from the entire internet
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "instance2" {
  name = "terraform_example_instance2"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "ssh"
    cidr_blocks = ["160.250.254.108"]
  }
}
