resource "aws_api_gateway_rest_api" "image_api" {
  name        = "ImageAPI"
  description = "Image Upload & Processing API"
}

resource "aws_api_gateway_resource" "upload" {
  rest_api_id = aws_api_gateway_rest_api.image_api.id
  parent_id   = aws_api_gateway_rest_api.image_api.root_resource_id
  path_part   = "upload"
}

resource "aws_api_gateway_method" "post_upload" {
  rest_api_id   = aws_api_gateway_rest_api.image_api.id
  resource_id   = aws_api_gateway_resource.upload.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_upload" {
  rest_api_id = aws_api_gateway_rest_api.image_api.id
  resource_id = aws_api_gateway_resource.upload.id
  http_method = aws_api_gateway_method.post_upload.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.image_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "api_deploy" {
  depends_on  = [aws_api_gateway_integration.lambda_upload]
  rest_api_id = aws_api_gateway_rest_api.image_api.id
  stage_name  = var.api_gateway_stage
}

