module "vpc" {
  source = "../modules/vpc"

  project_name           = var.project_name
  deployment_environment = var.deployment_environment
  default_tags           = var.default_tags
}
