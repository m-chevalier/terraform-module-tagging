terraform {
  required_providers {
    http = {
      source = "hashicorp/http"
      version = "3.4.0"
    }
  }
}

data "http" "project_info" {
  url = "" # PUT LAMBDA URL HERE
  request_body = jsonencode({ projectId = var.project_id})
  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }

  lifecycle {
    postcondition {
      condition     = jsondecode(self.response_body).Status != "unknown-project-id"
      error_message = "Project id ${var.project_id} is not a valid project id."
    }
  }
}

locals {
  remote_tags = {
    for key, value in jsondecode(data.http.project_info.response_body) :
    key => key == "Status" ? null : value
  }
  # We remove the status value because it's not a tag
  default_tags = {
    Environment = var.is_production ? "True" : "False"
    Project     = var.project_id
    IaC = "Terraform"
  }
  common_tags = merge(var.additional_tags, local.default_tags, local.remote_tags)
}