output "lambda_arn" {
  value = module.rsvp_subscription_api.lambda_arn
}

output "invoke_url" {
  value = module.rsvp_subscription_api.invoke_url
}

output "execution_arn" {
  value = module.rsvp_subscription_api.execution_arn
}

output "dynamo_db_arn" {
  value = module.rsvp_subscription_api.dynamo_db_arn
}

output "dynamo_db_name" {
  value = module.rsvp_subscription_api.dynamo_db_name
}
