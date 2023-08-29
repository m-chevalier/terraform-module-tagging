variable "is_production" {
  description = "Indique si la ressource fait partie d'un environnement de production"
  type        = bool
}

variable "project_id" {
  description = "Identifiant du projet issu de Workday"
  type        = string
  default = ""
}

variable "owner" {
  description = "Email du responsable de la ressource"
  type = string
  default = ""
}

variable "additional_tags" {
  description = "Tags supplémentaires"
  type = map(string)
  default = {}
}

variable "project_info_lambda_name" {
  description = "Nom de la lambda qui va être appelée pour vérifier le projectID et récupérer le Owner depuis Workday"
  type = string
  default = "project-infos"
}