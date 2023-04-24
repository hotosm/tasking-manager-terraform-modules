variable "project_name" {
  type    = string
  default = "tasking-manager"

  description = "Name of the project: tasking-manager by default"
}

variable "deployment_environment" {
  type    = string
  default = "staging"

  description = "Flavour of deployment"
}

variable "default_tags" {
  type = map(string)

  default = {
    Project       = "tasking-manager"
    Maintainer    = "example@acme.corp"
    Terraform_IaC = "true"
    cost_centre   = "gis-team@acme.corp"
  }

  description = "Default tags to apply to resources"
}

variable "aws_region" {
  type = map(string)

  default = {
    prod    = "us-east-1"
    staging = "us-east-1"
    dev     = "us-east-1"
  }

  description = "AWS in which to host the project"
}
