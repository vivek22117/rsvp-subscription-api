#############################
# Global Variables          #
#############################
variable "profile" {
  type = string
  description = "AWS profile name for credentials"
}

variable "default_region" {
  type = string
  description = "AWS region name to deploy resources"
}

variable "environment" {
  type = string
  description = "Environment to deploy, Valid values 'qa', 'dev', 'prod'"
}

#################################
#  Default Variables            #
#################################
variable "s3_bucket_prefix" {
    type = string
  description = "S3 deployment bucket prefix"
  default = "doubledigit-tfstate"
}


#################################
# Application Variables         #
#################################
variable "subscriber_api_lambda_handler" {
  type = string
  description = "AWS Lambda handler method name"
}

variable "subscriber_api_lambda" {
  type = string
  description = "AWS Lambda function name"
}

variable "db_table_name" {
  type = string
  description = "Name of the table for subscribers"
}

variable "hash_key" {
  type = string
  description = "DynamoDB table hash key"
}

variable "billing_mode" {
  type = string
  description = "DynamoDB Billing mode. Can be PROVISIONED or PAY_PER_REQUEST"
}

variable "db_read_capacity" {
  type = number
  description = "DynamoDB read capacity"
}

variable "db_write_capacity" {
  type = number
  description = "DynamoDB write capacity"
}

variable "enable_encryption" {
  type = bool
  description = "Enable DynamoDB server-side encryption"
}

variable "enable_point_in_time_recovery" {
  type = bool
  description = "Enable DynamoDB point in time recovery"
}

variable "lambda_memory" {
  type = string
  description = "AWS Lambda function memory limit"
}

variable "lambda_timeout" {
  type = string
  description = "AWS Lambda function timeout"
}

variable "subscriber_api_lambda_bucket_key" {
  type = string
  description = "S3 key to upload deployable zip file"
}

variable "add_subscription_path" {
  type        = string
  description = "URL path to add new subscription!"
}

variable "get_subscription_path" {
  type        = string
  description = "URL path to get all subscription!"
}

variable "delete_subscription_path" {
  type        = string
  description = "URL path to delete all subscription!"
}
####################################
# Local variables                  #
####################################
locals {
  common_tags = {
    owner       = "Vivek"
    team        = "DoubleDigitTeam"
    environment = var.environment
  }
}