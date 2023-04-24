variable "aws_region" {
  type    = string
  default = "us-east-1"

  description = "AWS Region to host the project in"
}

variable "aws_rfc1918" {
  type    = list(any)
  default = ["10.0.0.0/16", "172.31.0.0/16", "192.168.0.0/16"]

  description = "Modified RFC 1918 CIDR with AWS minimum /16 prefixes"
}

variable "project_name" {
  type    = string
  default = "tasking-manager"

  description = "Name of the project"
}

variable "project_revision" {
  type    = string
  default = "v4.5.4"

  description = "GIT revision of the project"
}

variable "deployment_environment" {
  type    = string
  default = "dev"

  description = "Flavour or deployment environment"
}

variable "domain_name_dot_tld" {
  type    = string
  default = "hotosm.org"

  description = "Domain name - this template builds on the assumption that domain is managed by AWS Route 53"
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

