output "lambda_arn" {
  value = aws_lambda_function.subscriber_api_lambda.arn
}

output "api_url" {
  value = aws_api_gateway_deployment.rsvp_api_deployment.invoke_url
}

output "execution_arn" {
  value = aws_api_gateway_deployment.rsvp_api_deployment.execution_arn
}

output "dynamo_db_arn" {
  value = aws_dynamodb_table.subscriber_table.arn
}

output "dynamo_db_name" {
  value = aws_dynamodb_table.subscriber_table.name
}
