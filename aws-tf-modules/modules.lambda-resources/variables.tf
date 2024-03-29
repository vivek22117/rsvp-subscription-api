#############################
# Global Variables          #
#############################
variable "default_region" {
  type        = string
  description = "AWS region name to deploy resources"
}

variable "environment" {
  type        = string
  description = "Environment to deploy, Valid values 'qa', 'dev', 'prod'"
}

variable "component_name" {
  type        = string
  description = "Component name for resources"
}


#################################
# Application Variables         #
#################################
variable "subscriber_api_lambda_handler" {
  type        = string
  description = "AWS Lambda handler method name"
}

variable "subscriber_api_lambda" {
  type        = string
  description = "AWS Lambda function name"
}

variable "db_table_name" {
  type        = string
  description = "Name of the table for subscribers"
}

variable "hash_key" {
  type        = string
  description = "DynamoDB table hash key"
}

variable "billing_mode" {
  type        = string
  description = "DynamoDB Billing mode. Can be PROVISIONED or PAY_PER_REQUEST"
}

variable "db_read_capacity" {
  type        = number
  description = "DynamoDB read capacity"
}

variable "db_write_capacity" {
  type        = number
  description = "DynamoDB write capacity"
}

variable "enable_encryption" {
  type        = bool
  description = "Enable DynamoDB server-side encryption"
}

variable "enable_point_in_time_recovery" {
  type        = bool
  description = "Enable DynamoDB point in time recovery"
}

variable "lambda_memory" {
  type        = string
  description = "AWS Lambda function memory limit"
}

variable "lambda_timeout" {
  type        = string
  description = "AWS Lambda function timeout"
}

variable "subscriber_api_lambda_bucket_key" {
  type        = string
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

variable "domain_name" {
  type        = string
  description = "domain name for API Gateway"
}

#####===============Tag variables==================#####
variable "common_tags" {
  type = map(string)
  validation {
    condition = alltrue([for t in ["Owner", "Team", "Env", "Monitoring", "Project", "Terraform", "Org", "CreatedOn"] : contains(keys(var.common_tags), t)])
    error_message = "Please specify required tags, ['Owner', 'Team', 'Env', 'Monitoring', 'Project', 'Terraform', 'Org', 'CreatedOn']."
  }
}

