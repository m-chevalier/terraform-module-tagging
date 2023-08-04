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

# data "http" "project_info" {
#   url = "" # PUT LAMBDA URL HERE
#   request_body = jsonencode({ projectId = var.project_id})
#   # Optional request headers
#   request_headers = {
#     Accept = "application/json"
#   }

#   lifecycle {
#     postcondition {
#       condition     = jsondecode(self.response_body).Status != "unknown-project-id"
#       error_message = "Project id ${var.project_id} is not a valid project id."
#     }
#   }
# }

data "aws_lambda_invocation" "example" {
  function_name = var.project_info_lambda_name

  input = jsonencode({ projectId = var.project_id})

  lifecycle {
    postcondition {
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
  remote_tags = {
    for key, value in jsondecode(data.aws_lambda_invocation.example.result) :
    key => key == "Status" ? null : value
  }
  # We remove the status value because it's not a tag
  default_tags = {
    Environment = var.is_production ? "True" : "False"
    ProjectID   = local.valid_project_id ? var.project_id : data.aws_organizations_resource_tags.account[0].tags.ProjectID
    IaC         = "Terraform"
    Requester = data.aws_caller_identity.current.arn
  }
  common_tags = merge(var.additional_tags, local.default_tags, local.remote_tags)
}