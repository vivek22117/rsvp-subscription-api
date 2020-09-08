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
variable "add_subscription_path" {
  type        = string
  description = "URL path to add new subscription!"
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