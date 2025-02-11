# 🚀 S3 Bucket for Image Storage (Private)
resource "aws_s3_bucket" "images" {
  bucket = var.s3_bucket_name
}

# 🚀 S3 Public Access Block for Images (Restrict Public Access)
resource "aws_s3_bucket_public_access_block" "images_block" {
  bucket = aws_s3_bucket.images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 🚀 S3 Bucket for Frontend Hosting (Public Read via CloudFront)
resource "aws_s3_bucket" "frontend" {
  bucket = var.frontend_bucket_name
}

# 🚀 S3 Public Access Block for Frontend (Allow Public Read)
resource "aws_s3_bucket_public_access_block" "frontend_block" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false  # Allow public read
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 🚀 Enable Static Website Hosting for Frontend
resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }
}

# 🚀 S3 Bucket Policy for Frontend (Allows CloudFront to Access)
resource "aws_s3_bucket_policy" "frontend_policy" {
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

