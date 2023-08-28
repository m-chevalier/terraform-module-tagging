terraform {
  required_providers {
    aws = {
      version = "~> 5.10.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-1"
}

data "aws_lambda_invocation" "lambda_projectinfos" {
  function_name = var.project_info_lambda_name

  # We set as input either the projectID parameter or the default projectID set on the AWS account
  input = jsonencode({ 
      projectId = local.valid_project_id ? var.project_id : data.aws_organizations_resource_tags.account[0].tags.ProjectID
  })

  lifecycle {
    postcondition {
      # We check if the lambda status is equals 'success' otherwise it will produce an error and we display the message
      condition     = jsondecode(self.result).status == "success"
      error_message = jsondecode(self.result).message
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_organizations_resource_tags" "account" {
  count = local.valid_project_id ? 0 : 1
  resource_id = "${data.aws_caller_identity.current.account_id}"
}

locals {
  valid_project_id = var.project_id != ""

  # We call the lambda
  lambda_result = jsondecode(data.aws_lambda_invocation.lambda_projectinfos.result)

  # We set the remote tags
  remote_tags = {
    Owner       = var.owner == "" ? local.lambda_result.owner : var.owner
  }
  
  # We set the default tags (that are set localy)
  default_tags = {
    Environment = var.is_production ? "True" : "False"
    ProjectID   = local.valid_project_id ? var.project_id : data.aws_organizations_resource_tags.account[0].tags.ProjectID
    IaC         = "Terraform"
    Requester = data.aws_caller_identity.current.arn
  }

  #We merge the default tags with the tags we obtained from the lambda 
  common_tags = merge(var.additional_tags, local.default_tags, local.remote_tags)
}