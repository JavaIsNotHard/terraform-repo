provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "example" {
  ami = "ami-0fb653ca2d3203ac1"
  instance_type = "t3.micro"
}
