provider "aws" {
  region = var.default_region
  profile = var.profile

  version >= "2.22.0"
}

provider "template" {
  version = "2.1.2"
}

provider "archive" {
  version = "1.2.2"
}

###########################################################
# Terraform configuration block is used to define backend #
# Interpolation syntax is not allowed in Backend          #
###########################################################
terraform {
  required_version = ">=0.12"

  backend "s3" {
    profile = "admin"
    bucket = "doubledigit-tfstate-qa-us-east-1"
    dynamodb_table = "doubledigit-tfstate-qa-us-east-1"
    key = "state/qa/api-gateway/kinesis-publisher/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}