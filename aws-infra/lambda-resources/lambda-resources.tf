############################################################
#        Adding the lambda archive to the defined bucket   #
############################################################
resource "aws_s3_bucket_object" "subscriber_api_package" {
  depends_on = [data.archive_file.kinesis_rsvp_publisher_lambda_jar]

  bucket = data.terraform_remote_state.s3_buckets.outputs.artifactory_s3_name
  key    = var.subscriber_api_lambda_bucket_key
  source = "${path.module}/lambda-package/lambda_processor.zip"
  etag   = filemd5("${path.module}/lambda-package/lambda_processor.zip")
}

data "archive_file" "kinesis_rsvp_publisher_lambda_jar" {
  type        = "zip"
  source_file = "../../subscription-api-lambda/lambda_processor.py"
  output_path = "${path.module}/lambda-package/lambda_processor.zip"
}


resource "aws_lambda_function" "subscriber_api_lambda" {
  depends_on = [aws_iam_role.k_lambda_k_role, aws_iam_policy.kinesis_lambda_policy]

  description = "Lambda function to save kinesis subscribers!"

  function_name = var.subscriber_api_lambda
  handler       = var.subscriber_api_lambda_handler

  s3_bucket = aws_s3_bucket_object.subscriber_api_package.bucket
  s3_key    = aws_s3_bucket_object.subscriber_api_package.key

  //  filename = data.archive_file.kinesis_rsvp_publisher_lambda_jar.output_path
  //  source_code_hash = data.archive_file.kinesis_rsvp_publisher_lambda_jar.output_base64sha256
  role = aws_iam_role.k_lambda_k_role.arn

  memory_size = var.lambda_memory
  timeout     = var.lambda_timeout
  runtime     = "python3.8"

  environment {
    variables = {
      environment     = var.environment
      subscriberTable = aws_dynamodb_table.subscriber_table.name
    }
  }

  tags = merge(local.common_tags, map("Name", "${var.environment}-rsvp-subscribers-processor"))
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.subscriber_api_lambda.arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.rsvp_subscriber_api.execution_arn}/*/*/*"
}
