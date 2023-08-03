terraform {
  required_providers {
    http = {
      source = "hashicorp/http"
      version = "3.4.0"
    }
    aws = {
      version = "~> 5.10.0"
    }
  }
}

data "http" "project_info" {
  url = "https://catfact.ninja/fact"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}

data "aws_caller_identity" "current" {}

data "aws_organizations_resource_tags" "account" {
  resource_id = "${data.aws_caller_identity.current.account_id}"
}

locals {
  remote_tags = jsondecode(data.http.project_info.response_body)
  default_tags = {
    Environment = var.is_production ? "True" : "False"
    ProjectID   = var.project_id != "" ? var.project_id : data.aws_organizations_resource_tags.account.tags.ProjectID
    IaC         = "Terraform"
  }
  common_tags = merge(var.additional_tags, local.default_tags, local.remote_tags)
}