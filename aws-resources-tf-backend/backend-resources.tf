#####============================Terraform tfstate backend S3==========================#####
resource "aws_s3_bucket" "tf_state_backend_bucket" {
  bucket = "${var.environment}-rsvp-subscription-api-tfstate-${data.aws_caller_identity.current.account_id}-${var.default_region}"
  acl    = "private"

  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true
    id      = "state"
    prefix  = "state/"

    noncurrent_version_expiration {
      days = 30
    }
  }

  tags = merge(local.common_tags, tomap({ "Name" = "${var.environment}-tfstate-bucket" }))
}


#####=========================DynamoDB Table for tfstate state lock===========================#####
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name           = "${var.environment}-rsvp-subscription-api-tfstate-lock-db-${var.default_region}"
  read_capacity  = 2
  write_capacity = 2

  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = false
  }

  tags = merge(local.common_tags, tomap({ "Name" = "${var.environment}-tfstate-db" }))
}
