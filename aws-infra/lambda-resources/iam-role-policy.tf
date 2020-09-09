resource "aws_iam_role" "k_lambda_k_role" {
  depends_on = ["aws_iam_policy.kinesis_lambda_policy"]

  name ="KinesisLambdaPublisherRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}


resource "aws_iam_policy" "kinesis_lambda_policy" {
  name = "KinesisLambdaPublisherPolicy"
  description = "Policy to access DynamoDB and Kinesis"
  path = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:DescribeTable",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:PutItem",
        "dynamodb:GetItem"
      ],
      "Resource": "${aws_dynamodb_table.subscriber_table.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
                "kinesis:DescribeStream",
                "kinesis:DescribeStreamSummary",
                "kinesis:GetRecords",
                "kinesis:GetShardIterator",
                "kinesis:ListShards",
                "kinesis:ListStreams",
                "kinesis:SubscribeToShard"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_kinesis_policy_role_att" {
  policy_arn = aws_iam_policy.kinesis_lambda_policy.arn
  role       = aws_iam_role.k_lambda_k_role.name
}