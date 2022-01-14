output "lambda_arn" {
  value = aws_lambda_function.subscriber_api_lambda.arn
}

output "domain_name" {
  value = aws_api_gateway_base_path_mapping.api.domain_name
}

output "execution_arn" {
  value = aws_api_gateway_rest_api.rsvp_subscriber_api.execution_arn
}

output "dynamo_db_arn" {
  value = aws_dynamodb_table.subscriber_table.arn
}

output "dynamo_db_name" {
  value = aws_dynamodb_table.subscriber_table.name
}
