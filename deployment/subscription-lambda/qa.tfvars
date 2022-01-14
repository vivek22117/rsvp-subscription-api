default_region = "us-east-1"

subscriber_api_lambda_bucket_key = "lambda-package/rsvp-subscriber/rsvp-subscriber-api.zip"
subscriber_api_lambda_handler    = "lambda_processor.lambda_handler"
subscriber_api_lambda            = "RSVPSubscriberAPIHandler"

add_subscription_path    = "add-subscription"
get_subscription_path    = "get-all"
delete_subscription_path = "delete-subscription"

db_table_name                 = "rsvp-subscribers-table"
hash_key                      = "ResourceName"
billing_mode                  = "PROVISIONED"
enable_encryption             = true
enable_point_in_time_recovery = false
db_read_capacity              = 2
db_write_capacity             = 2

domain_name = "rsvp-subscription-api"

lambda_memory  = "384"
lambda_timeout = "60"