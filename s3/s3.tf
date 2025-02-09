provider "aws" {
  region = "eu-north-1" # Change to your preferred region
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "demo-image-root-bucket"

  tags = {
    Name        = "RootImageBucket"
    Environment = "Dev"
  }
}
