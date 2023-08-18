variable "is_production" {
  description = "Indicates if the environment is Production"
  type        = bool
}

variable "project_id" {
  description = "ID of the project"
  type        = string
  default = ""
}

variable "owner" {
  description = "Email of the manager of the resource"
  type = string
  default = ""
}

variable "additional_tags" {
  description = "Additional tags"
  type = map(string)
  default = {}
}

variable "project_info_lambda_name" {
  description = "Name of the lambda which will be called to get informations about the project"
  type = string
  default = "project-infos"
}