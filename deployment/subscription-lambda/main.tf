############################################################
#        RSVP Subscription AMP module implementation       #
############################################################
module "rsvp_subscription_api" {
  source = "../../aws-tf-modules/modules.lambda-resources"

  environment    = var.environment
  default_region = var.default_region

  add_subscription_path = var.add_subscription_path
  billing_mode          = var.billing_mode
  db_read_capacity      = var.db_read_capacity
  db_table_name         = var.db_table_name
  db_write_capacity     = var.db_write_capacity

  delete_subscription_path      = var.delete_subscription_path
  domain_name                   = var.domain_name
  enable_encryption             = var.enable_encryption
  enable_point_in_time_recovery = var.enable_point_in_time_recovery
  get_subscription_path         = var.get_subscription_path

  hash_key                         = var.hash_key
  lambda_memory                    = var.lambda_memory
  lambda_timeout                   = var.lambda_timeout
  subscriber_api_lambda            = var.subscriber_api_lambda
  subscriber_api_lambda_bucket_key = var.subscriber_api_lambda_bucket_key
  subscriber_api_lambda_handler    = var.subscriber_api_lambda_handler
}
