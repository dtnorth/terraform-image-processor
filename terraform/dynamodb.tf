# Create a Customer-Managed KMS Key for DynamoDB Encryption
resource "aws_kms_key" "dynamodb_kms" {
  description             = "KMS key for encrypting DynamoDB table"
  enable_key_rotation     = true
}

resource "aws_kms_alias" "dynamodb_kms_alias" {
  name          = "alias/dynamodb-key"
  target_key_id = aws_kms_key.dynamodb_kms.key_id
}

# Create DynamoDB Table with KMS Encryption
resource "aws_dynamodb_table" "urls" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "shortId"

  attribute {
    name = "shortId"
    type = "S"
  }

  # Enable Customer-Managed KMS Encryption
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb_kms.arn
  }
}

