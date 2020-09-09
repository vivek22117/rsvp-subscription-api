####################################################
#adding the lambda archive to the defined bucket   #
####################################################
resource "aws_s3_bucket_object" "kinesis_rsvp_publisher_package" {
  depends_on = ["data.archive_file.kinesis_rsvp_publisher_lambda_jar"]

  bucket = data.terraform_remote_state.backend.outputs.deploy_bucket_name
  key    = var.kinesis_lambda_kinesis_bucket_key
  source = "${path.module}/../../KinesisPublisher/target/kinesis-rsvp-publisher-1.0.0-lambda.zip"
  etag   = filemd5("${path.module}/../../KinesisPublisher/target/kinesis-rsvp-publisher-1.0.0-lambda.zip")
}

data "archive_file" "kinesis_rsvp_publisher_lambda_jar" {
  type        = "zip"
  source_file = "${path.module}/../../KinesisPublisher/target/kinesis-rsvp-publisher-1.0.0.jar"
  output_path = "kinesis-rsvp-publisher-lambda-jar/rsvp_lambda_publisher.zip"
}


resource "aws_lambda_function" "kinesis_rsvp_lambda_publisher" {
  depends_on = ["aws_iam_role.k_lambda_k_role", "aws_iam_policy.kinesis_lambda_policy"]

  description = "Lambda function to publish RSVP records!"

  function_name = var.kinesis_publisher_lambda
  handler       = var.kinesis_publisher_lambda_handler

  s3_bucket = aws_s3_bucket_object.kinesis_rsvp_publisher_package.bucket
  s3_key    = aws_s3_bucket_object.kinesis_rsvp_publisher_package.key

  source_code_hash = data.archive_file.kinesis_rsvp_publisher_lambda_jar.output_base64sha256
  role             = aws_iam_role.k_lambda_k_role.arn

  memory_size = var.lambda_memory
  timeout     = var.lambda_timeout
  runtime     = "java8"

  environment {
    variables = {
      isRunningInLambda = "true",
      environment = var.environment
    }
  }

  tags = merge(local.common_tags, map("Name", "${var.environment}-rsvp-kinesis-publisher"))
}

resource "aws_lambda_event_source_mapping" "kinesis_lambda_event_mapping" {
  depends_on = ["aws_iam_role.k_lambda_k_role", "aws_lambda_function.kinesis_rsvp_lambda_publisher"]

  batch_size        = 100
  event_source_arn  = data.terraform_remote_state.rsvp_lambda_kinesis.outputs.kinesis_arn
  function_name     = aws_lambda_function.kinesis_rsvp_lambda_publisher.arn
  enabled           = true
  starting_position = "TRIM_HORIZON"
}