variable "project_name" {
  type    = string
  default = "tasking-manager"

  description = "Name of the project: tasking-manager by default"
}

variable "deployment_environment" {
  type    = string
  default = "dev"

  description = "Flavour of deployment"
  validation {
    condition = contains(
      [
        "prod",
        "production",
        "stage",
        "staging",
        "dev",
        "development",
        "test",
        "testing",
        "uat"
      ],
      var.deployment_environment
    )
    error_message = "Deployment_environment must conform to allowed values"
  }
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

variable "backup" {
  type = map(string)

  default = {
    final_snapshot_identifier = "hello"
  }
}

variable "rds_opts" {
  description = "RDS Options"

  type = map(string)
  default = {
    instance_class = "db.t4g.small"
    multi_az       = false
  }
}
