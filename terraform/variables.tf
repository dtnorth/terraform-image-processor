variable "aws_region" { default = "us-east-1" }
variable "s3_bucket_name" { default = "image-storage-platform" }
variable "frontend_bucket_name" { default = "image-platform-frontend" }
variable "lambda_function_name" { default = "ImageService" }
variable "api_gateway_stage" { default = "dev" }
variable "dynamodb_table_name" { default = "ShortURLs" }
variable "use_custom_domain" { default = false }
variable "route53_zone_id" { default = "" }
