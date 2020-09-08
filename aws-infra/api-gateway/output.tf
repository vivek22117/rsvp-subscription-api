# URL to invoke the API
output "url" {
  value = aws_api_gateway_deployment.rsvp_api_deployment.invoke_url
}

output "execution_arn" {
  value = aws_api_gateway_deployment.rsvp_api_deployment.execution_arn
}