provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "jibesh-terraform-state-bucket"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-table"
    encrypt        = true
  }
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.state-file-bucket.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.lock-table.name
  description = "The name of the DynamoDB table"
}

resource "aws_s3_bucket" "state-file-bucket" {
  bucket = "jibesh-terraform-state-bucket"

  // terraform will not let you delete this bucket
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "aws_s3_bucket_versioning" "state-file-bucket-version" {
  bucket = aws_s3_bucket.state-file-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state-file-bucket-encrypt" {
  bucket = aws_s3_bucket.state-file-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state-file-bucket-acl" {
  bucket                  = aws_s3_bucket.state-file-bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "lock-table" {
  name         = "terraform-state-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
