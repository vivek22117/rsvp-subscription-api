############################################################
#        Adding the lambda archive to the defined bucket   #
############################################################
resource "random_uuid" "s3_path_uuid" {

  keepers = {
    for filename in fileset("${path.module}/../../subscription-api-lambda/", "*.py") :

    filename => filemd5("${path.module}/../../subscription-api-lambda//${filename}")
  }
}

resource "null_resource" "trigger_new_deployment" {
  triggers = {
    source_code_has = random_uuid.s3_path_uuid.result
  }
}


data "archive_file" "subscriber_api_package_zip" {
  depends_on = [null_resource.trigger_new_deployment]

  type        = "zip"
  source_file = "${path.module}/../../subscription-api-lambda/lambda_processor.py"
  output_path = "${path.module}/lambda-package/lambda_processor.zip"
}

#####################################################
# adding the lambda archive to the defined bucket   #
#####################################################
resource "aws_s3_object" "subscriber_api_package" {
  depends_on = [data.archive_file.subscriber_api_package_zip]

  bucket      = data.terraform_remote_state.s3_buckets.outputs.artifactory_s3_name
  key         = "${random_uuid.s3_path_uuid.result}/${var.subscriber_api_lambda_handler}"
  source      = data.archive_file.subscriber_api_package_zip.output_path
  source_hash = data.archive_file.subscriber_api_package_zip.output_base64sha256
}


resource "aws_lambda_function" "subscriber_api_lambda" {
  depends_on = [
    aws_iam_role.k_lambda_k_role,
    aws_iam_policy.kinesis_lambda_policy,
    aws_s3_object.s3_object
  ]

  description = "Lambda function to save kinesis subscribers!"

  function_name = var.subscriber_api_lambda
  handler       = var.subscriber_api_lambda_handler

  s3_bucket        = aws_s3_object.subscriber_api_package.bucket
  s3_key           = aws_s3_object.subscriber_api_package.key
  source_code_hash = data.archive_file.subscriber_api_package_zip.output_base64sha256

  role = aws_iam_role.k_lambda_k_role.arn

  memory_size = var.lambda_memory
  timeout     = var.lambda_timeout
  runtime     = "python3.9"

  environment {
    variables = {
      environment     = var.environment
      subscriberTable = aws_dynamodb_table.subscriber_table.name
      S3KeyForPackage = "${random_uuid.s3_path_uuid.result}/${var.subscriber_api_lambda_handler}"
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }

  tags = merge(var.common_tags, tomap({
    "CreatedOn" = timestamp()
    "Name"      = "${var.environment}-${var.component_name}-processor"
  }))

}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.subscriber_api_lambda.arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.rsvp_subscriber_api.execution_arn}/*/*/*"
}

resource "aws_cloudwatch_log_group" "lambda_processor_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.subscriber_api_lambda.id}"
  retention_in_days = 30

  lifecycle {
    ignore_changes = [tags]
  }

  tags = merge(var.common_tags, tomap({
    "CreatedOn" = timestamp()
    "Name"      = "${aws_lambda_function.subscriber_api_lambda.id}-lg"
  }))
}