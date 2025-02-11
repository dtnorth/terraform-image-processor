provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "terraform-state-bucket"
    key    = "image-platform/terraform.tfstate"
    region = var.aws_region
  }
}
