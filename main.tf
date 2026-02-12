provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami = "ami-0b6c6ebed2801a5cb"
  instance_type = "t3.micro"

  user_data = <<-EOF
              #!/bin/sh
              echo "Hello World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  // the user_data_replace_on_change option is set to true so that when you change the user_data parameter and run apply, terraform will terminate the origin instance and launch a new one
  user_data_replace_on_change = true

  tags = {
    Name = "terraform-example"
  }
}