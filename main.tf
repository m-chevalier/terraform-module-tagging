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

  # We send either the projectID parameter or the default projectID set on the AWS account
  # We also send owner varaible value in order to get the project manager email in case of empty string
  input = jsonencode(
    { 
      projectId = local.valid_project_id ? var.project_id : data.aws_organizations_resource_tags.account[0].tags.ProjectID,
      owner = var.owner
    }
    )

  lifecycle {
    postcondition {
      # We check if the lambda status is equals 'success' otherwise it will produce an error
      condition     = jsondecode(self.result).Status == "success"
      error_message = "Project id ${var.project_id} is not a valid project id."
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

  # We remove the status value returned by the lambda because it's not a tag
  remote_tags = {
    for key, value in jsondecode(data.aws_lambda_invocation.lambda_projectinfos.result) :
    key => key == "Status" ? null : value
  }
  
  # We set the default tags (that are set localy)
  default_tags = {
    Environment = var.is_production ? "True" : "False"
    ProjectID   = local.valid_project_id ? var.project_id : data.aws_organizations_resource_tags.account[0].tags.ProjectID
    IaC         = "Terraform"
    Requester = data.aws_caller_identity.current.arn
    Owner     = var.owner
  }

  #We merge the default tags with the tags we obtained from the lambda 
  common_tags = merge(var.additional_tags, local.default_tags, local.remote_tags)
}