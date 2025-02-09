resource "aws_dynamodb_table" "url_shortener" {
  name         = "UrlShortener"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "shortId"

  attribute {
    name = "shortId"
    type = "S"
  }
}

resource "aws_lambda_function" "image_lambda" {
  function_name = "ImageService"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "nodejs18.x"
  handler       = "server.handler"
  s3_bucket     = aws_s3_bucket.lambda_bucket.id
  s3_key        = "lambda.zip"

  environment {
    variables = {
      S3_BUCKET             = aws_s3_bucket.images_bucket.id
      URL_SHORTENER_TABLE   = aws_dynamodb_table.url_shortener.id
    }
  }
}

