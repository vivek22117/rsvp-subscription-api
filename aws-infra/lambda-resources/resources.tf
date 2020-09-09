####################################################
#          AWS DynamoDB for Subscriber             #
####################################################
resource "aws_dynamodb_table" "subscriber_table" {
  name = var.db_table_name

  hash_key = var.hash_key
  billing_mode = var.billing_mode

  read_capacity = var.db_read_capacity
  write_capacity = var.db_write_capacity

  server_side_encryption {
    enabled = var.enable_encryption
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  attribute {
    name = var.hash_key
    type = "S"
  }

  tags = merge(local.common_tags, map("Name", "subscriber-dynamoDB"))
}