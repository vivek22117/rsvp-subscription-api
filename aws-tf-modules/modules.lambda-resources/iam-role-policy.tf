resource "aws_iam_role" "k_lambda_k_role" {
  depends_on = [aws_iam_policy.kinesis_lambda_policy]

  name               = "RSVPSubscriberAPILambdaRole"
  path               = "/"
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

  lifecycle {
    ignore_changes = [tags]
  }

  tags = merge(var.common_tags, tomap({
    "CreatedOn" = timestamp()
    "Name"      = "${var.environment}-${var.component_name}-role"
  }))
}


resource "aws_iam_policy" "kinesis_lambda_policy" {
  name        = "RSVPSubscriberAPILambdaPolicy"
  description = "Policy to access DynamoDB and Kinesis"
  path        = "/"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "s3:Get*",
          "s3:Put*",
          "s3:List*"
      ],
      "Resource": [
          "${data.terraform_remote_state.s3_buckets.outputs.artifactory_s3_arn}",
          "${data.terraform_remote_state.s3_buckets.outputs.artifactory_s3_arn}/*"
        ]
    },
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
        "dynamodb:GetItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "${aws_dynamodb_table.subscriber_table.arn}"
    }
  ]
}
EOF

  lifecycle {
    ignore_changes = [tags]
  }

  tags = merge(var.common_tags, tomap({
    "CreatedOn" = timestamp()
    "Name"      = "${var.environment}-${var.component_name}-policy"
  }))

}

resource "aws_iam_role_policy_attachment" "lambda_kinesis_policy_role_att" {
  policy_arn = aws_iam_policy.kinesis_lambda_policy.arn
  role       = aws_iam_role.k_lambda_k_role.name
}
