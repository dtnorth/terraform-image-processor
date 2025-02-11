resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id   = "S3Frontend"
  }

  default_cache_behavior {
    target_origin_id       = "S3Frontend"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

