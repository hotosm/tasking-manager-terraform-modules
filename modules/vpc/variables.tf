variable "aws_rfc1918" {
  description = "Modified RFC 1918 CIDR with AWS minimum /16 prefixes"

  type    = list(any)
  default = ["10.0.0.0/16", "172.31.0.0/16", "192.168.0.0/16"]
}

variable "project_name" {
  description = "Name of the project"

  type    = string
  default = "tasking-manager"
}

variable "deployment_environment" {
  description = "Flavour or deployment environment"

  type    = string

  validation {
    condition = contains(
      [
        "prod",
        "production",
        "dev",
        "development",
        "stage",
        "staging",
        "uat",
        "test"
      ],
      var.deployment_environment
    )
    error_message = "The deployment_environment string does not conform to allowed values"
  }
}

variable "default_tags" {
  description = "Default resource tags to apply to AWS resources"
  type        = map(string)

  default = {
    Project        = "tasking-manager"
    Maintainer     = "Humanitarian Openstreetmap Team"
    Documentation  = "docs.hotosm.org/taskingmanager"
    IaC_Management = "Terraform"
    cost_center    = "tasking-manager"
  }
}

