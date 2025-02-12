# S3 Bucket for Frontend Hosting
resource "aws_s3_bucket" "frontend-s3" {
  bucket = var.frontend_bucket_name
}

# Public Access Block for Frontend (Allows Public Read)
resource "aws_s3_bucket_public_access_block" "frontend_block_s3" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false  # Allow public read access
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Enable Static Website Hosting
resource "aws_s3_bucket_website_configuration" "frontend_bucket_s3" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }
}

# Make Frontend Bucket Publicly Accessible (CloudFront Needs This)
resource "aws_s3_bucket_policy" "frontend_policy_bucket" {
  bucket = aws_s3_bucket.frontend.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject",
      Effect    = "Allow",
      Principal = "*",
      Action    = "s3:GetObject",
      Resource  = "${aws_s3_bucket.frontend.arn}/*"
    }]
  })
}

