############################################
#     Configure API Gateway Logging        #
############################################
resource "aws_api_gateway_account" "rsvp_subscriber_api_config" {
  cloudwatch_role_arn = aws_iam_role.rsvp_processor_api_role.arn
}

resource "aws_iam_role" "rsvp_processor_api_role" {
  name = "RSVPSubscriberAPIGatewayRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "email_processor_policy" {
  name = "RSVPSubscriberAPIGatewayPolicy"
  role = aws_iam_role.rsvp_processor_api_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


############################################
#             API Gateway REST API         #
############################################
resource "aws_api_gateway_rest_api" "rsvp_subscriber_api" {
  # The name of the REST API
  name = "RSVPSubscriberAPI"

  description = "REST API to add new RSVP Subscribers!"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


#########################################################################
# API Gateway resource, which is a certain path inside the REST API     #
#########################################################################
resource "aws_api_gateway_resource" "post_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  parent_id   = aws_api_gateway_rest_api.rsvp_subscriber_api.root_resource_id

  path_part = var.add_subscription_path
}


resource "aws_api_gateway_resource" "get_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  parent_id   = aws_api_gateway_rest_api.rsvp_subscriber_api.root_resource_id

  path_part = var.get_subscription_path
}

resource "aws_api_gateway_resource" "delete_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  parent_id   = aws_api_gateway_rest_api.rsvp_subscriber_api.root_resource_id

  path_part = var.delete_subscription_path
}


#################################################################
# HTTP GET method to a API Gateway resource (REST endpoint)    #
#################################################################
resource "aws_api_gateway_method" "rsvp_api_method_GET" {
  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  resource_id = aws_api_gateway_resource.get_api_resource.id

  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method_settings" "get_enable_logging" {
  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  stage_name  = aws_api_gateway_deployment.rsvp_api_deployment.stage_name
  method_path = "${aws_api_gateway_resource.get_api_resource.path_part}/${aws_api_gateway_method.rsvp_api_method_GET.http_method}"

  settings {
    metrics_enabled    = true
    data_trace_enabled = true
    logging_level      = "INFO"
  }
}


resource "aws_api_gateway_method_response" "get_api_method_response_200" {
  depends_on = [aws_api_gateway_method.rsvp_api_method_GET]

  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  resource_id = aws_api_gateway_resource.get_api_resource.id
  http_method = aws_api_gateway_method.rsvp_api_method_GET.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration" "get_rsvp_api_integration" {
  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  resource_id = aws_api_gateway_resource.get_api_resource.id
  http_method = aws_api_gateway_method.rsvp_api_method_GET.http_method

  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.subscriber_api_lambda.invoke_arn
}


#----------------------------------------------------#
#               Enable CORS                          #
#----------------------------------------------------#
resource "aws_api_gateway_method" "get_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  resource_id   = aws_api_gateway_resource.get_api_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "get_options_200" {
  depends_on = [aws_api_gateway_method.get_options_method]

  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  resource_id = aws_api_gateway_resource.get_api_resource.id
  http_method = aws_api_gateway_method.get_options_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}


resource "aws_api_gateway_integration" "get_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  resource_id = aws_api_gateway_resource.get_api_resource.id
  http_method = aws_api_gateway_method.get_options_method.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
      {
        "statusCode": 200
        }
    EOF

  }
}

resource "aws_api_gateway_integration_response" "get_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  resource_id = aws_api_gateway_resource.get_api_resource.id
  http_method = aws_api_gateway_method.get_options_method.http_method
  status_code = aws_api_gateway_method_response.get_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}


#################################################################
# HTTP POST method to a API Gateway resource (REST endpoint)    #
#################################################################
resource "aws_api_gateway_method" "rsvp_api_method_POST" {
  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  resource_id = aws_api_gateway_resource.post_api_resource.id

  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_settings" "post_enable_logging" {
  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  stage_name  = aws_api_gateway_deployment.rsvp_api_deployment.stage_name
  method_path = "${aws_api_gateway_resource.post_api_resource.path_part}/${aws_api_gateway_method.rsvp_api_method_POST.http_method}"

  settings {
    metrics_enabled    = true
    data_trace_enabled = true
    logging_level      = "INFO"
  }
}


resource "aws_api_gateway_method_response" "post_api_method_response_200" {
  depends_on = [aws_api_gateway_method.rsvp_api_method_POST]

  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  resource_id = aws_api_gateway_resource.post_api_resource.id
  http_method = aws_api_gateway_method.rsvp_api_method_POST.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration" "rsvp_api_integration" {
  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  resource_id = aws_api_gateway_resource.post_api_resource.id

  http_method             = aws_api_gateway_method.rsvp_api_method_POST.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.subscriber_api_lambda.invoke_arn
}

#----------------------------------------------------#
#               Enable CORS                          #
#----------------------------------------------------#
resource "aws_api_gateway_method" "post_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  resource_id   = aws_api_gateway_resource.post_api_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "post_options_200" {
  depends_on = [aws_api_gateway_method.post_options_method]

  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  resource_id = aws_api_gateway_resource.post_api_resource.id
  http_method = aws_api_gateway_method.post_options_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}


resource "aws_api_gateway_integration" "post_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  resource_id = aws_api_gateway_resource.post_api_resource.id
  http_method = aws_api_gateway_method.post_options_method.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
      {
        "statusCode": 200
        }
    EOF

  }
}

resource "aws_api_gateway_integration_response" "post_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  resource_id = aws_api_gateway_resource.post_api_resource.id
  http_method = aws_api_gateway_method.post_options_method.http_method
  status_code = aws_api_gateway_method_response.post_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

#################################################################
# HTTP DELETE method to a API Gateway resource (REST endpoint)    #
#################################################################
resource "aws_api_gateway_method" "rsvp_api_method_DELETE" {
  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  resource_id = aws_api_gateway_resource.delete_api_resource.id

  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_method_settings" "delete_enable_logging" {
  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  stage_name  = aws_api_gateway_deployment.rsvp_api_deployment.stage_name
  method_path = "${aws_api_gateway_resource.delete_api_resource.path_part}/${aws_api_gateway_method.rsvp_api_method_DELETE.http_method}"

  settings {
    metrics_enabled    = true
    data_trace_enabled = true
    logging_level      = "INFO"
  }
}


resource "aws_api_gateway_method_response" "delete_api_method_response_200" {
  depends_on = [aws_api_gateway_method.rsvp_api_method_DELETE]

  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  resource_id = aws_api_gateway_resource.delete_api_resource.id
  http_method = aws_api_gateway_method.rsvp_api_method_DELETE.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration" "rsvp_delete_api_integration" {
  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  resource_id = aws_api_gateway_resource.delete_api_resource.id

  http_method             = aws_api_gateway_method.rsvp_api_method_DELETE.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.subscriber_api_lambda.invoke_arn
}

#----------------------------------------------------#
#               Enable CORS                          #
#----------------------------------------------------#
resource "aws_api_gateway_method" "delete_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  resource_id   = aws_api_gateway_resource.delete_api_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "delete_options_200" {
  depends_on = [aws_api_gateway_method.delete_options_method]

  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  resource_id = aws_api_gateway_resource.delete_api_resource.id
  http_method = aws_api_gateway_method.delete_options_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}


resource "aws_api_gateway_integration" "delete_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  resource_id = aws_api_gateway_resource.delete_api_resource.id
  http_method = aws_api_gateway_method.delete_options_method.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
      {
        "statusCode": 200
        }
    EOF

  }
}

resource "aws_api_gateway_integration_response" "delete_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  resource_id = aws_api_gateway_resource.delete_api_resource.id
  http_method = aws_api_gateway_method.delete_options_method.http_method
  status_code = aws_api_gateway_method_response.delete_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}


####################################
#     API Gateway deployment       #
####################################
resource "aws_api_gateway_deployment" "rsvp_api_deployment" {
  depends_on = [aws_api_gateway_integration.rsvp_api_integration]

  rest_api_id = aws_api_gateway_rest_api.rsvp_subscriber_api.id
  stage_name  = var.environment

  # Redeploy when there are new updates
  triggers = {
    redeployment = sha1(join(",", list(
      jsonencode(aws_api_gateway_integration.rsvp_api_integration),
    )))
  }

  lifecycle {
    create_before_destroy = true
  }
}


//#####################
//# SSL custom domain #
//#####################
//
//data "aws_acm_certificate" "api" {
//  domain = var.domain_name
//}
//
//resource "aws_api_gateway_domain_name" "api" {
//  domain_name     = var.domain_name
//  certificate_arn = data.aws_acm_certificate.api.arn
//}
//
//resource "aws_api_gateway_base_path_mapping" "api" {
//  api_id      = aws_api_gateway_rest_api.rsvp_subscriber_api.id
//  stage_name  = aws_api_gateway_deployment.rsvp_api_deployment.stage_name
//  domain_name = aws_api_gateway_domain_name.api.domain_name
//}