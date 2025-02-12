# IAM Role for Lambda Execution (with X-Ray Permissions)
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach X-Ray Permissions to Lambda Role
resource "aws_iam_policy_attachment" "lambda_xray" {
  name       = "lambda-xray-attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# Lambda Function with X-Ray Enabled
resource "aws_lambda_function" "image_lambda" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  runtime       = "nodejs18.x"
  handler       = "server.handler"
  filename      = "backend/lambda.zip"

  tracing_config {
    mode = "Active"  # Enables X-Ray tracing
  }

  environment {
    variables = {
      S3_BUCKET  = aws_s3_bucket.images.id
      TABLE_NAME = aws_dynamodb_table.urls.id
    }
  }
}

