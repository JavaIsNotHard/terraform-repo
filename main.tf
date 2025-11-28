provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "example" {
  ami = "ami-0fb653ca2d3203ac1"
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

