terraform {
  required_providers {
    http = {
      source = "hashicorp/http"
      version = "3.4.0"
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

locals {
  remote_tags = jsondecode(data.http.project_info.response_body)
  default_tags = {
    Environment = var.is_production
    Project     = var.project_id
    
  }
  common_tags = merge(local.default_tags, local.remote_tags)
}