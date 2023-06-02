variable "aws_region" {
  description = "AWS Region to host the project in"
  type        = string

  default = "us-east-1"
}

variable "aws_rfc1918" {
  description = "Modified RFC 1918 CIDR with AWS minimum /16 prefixes"
  type        = list(any)

  default = ["10.0.0.0/16", "172.31.0.0/16", "192.168.0.0/16"]
}

variable "project_name" {
  description = "Name of the project"
  type        = string

  default = "tasking-manager"
}

variable "project_revision" {
  description = "GIT revision of the project"
  type        = string

  default = "v4.5.4"
}

variable "deployment_environment" {
  description = "Flavour or deployment environment"
  type        = string

  default = "dev"
}

variable "domain_name_dot_tld" {
  description = "Domain name - this template builds on the assumption that domain is managed by AWS Route 53"
  type        = string

  default = "hotosm.org"
}

variable "sub_domain_prefix" {
  type = string

  default = ""
}

variable "ssl_protocol_versions" {
  type = map(string)

  default = {
    client_to_cdn          = "TLSv1.2_2021"
    client_to_loadbalancer = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  }
}

variable "default_tags" {
  type = map(string)

  default = {
    Project        = "tasking-manager"
    Maintainer     = "DK_Benjamin Yogesh_Girikumar Ramya_Ragupathy and Kathmandu_Living_Labs"
    Documentation  = "docs.hotosm.org/tasking_manager_infra"
    IaC_Management = "Terraform"
  }
}

variable "repository" {
  type = map(string)

  default = {
    uri                     = "https://github.com/hotosm/tasking-manager"
    branch                  = "develop"
    branch_display_name     = "develop"
    branch_deployment_stage = "DEVELOPMENT"
  }

  validation {
    condition = contains(
      [
        "PRODUCTION",
        "BETA",
        "DEVELOPMENT",
        "EXPERIMENTAL",
        "PULL_REQUEST"
      ],
      lookup(var.repository, "branch_deployment_stage")
    )
    error_message = "Stage should be one of the allowed values"
  }
}

variable "amplify_config_environment_variables" {
  description = "Environment variables specific to AWS Amplify"
  type        = map(string)

  default = {
    AMPLIFY_MONOREPO_APP_ROOT = "frontend"
    AMPLIFY_DIFF_DEPLOY       = "false"
  }
}

variable "environment_variables" {
  description = "Environment variables to supply to the frontend app"
  type        = map(string)

  default = {
    TM_APP_API_URL = "https://api.example.com"
  }
}

variable "access_token" {
  description = "Personal access token to access Github repositories"
  type        = string
  sensitive   = true

  default = ""
}

variable "secrets_store_credential_names" {
  description = "Names of entries in AWS Secrets Manager to use in Frontend module"
  type        = map(string)

  default = {
    oauth2_app_connect = ""
  }
}
