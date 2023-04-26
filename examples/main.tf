module "vpc" {
  source = "../modules/vpc"

  project_name           = var.project_name
  deployment_environment = var.deployment_environment
  default_tags           = var.default_tags
}

module "database" {
  source = "../modules/database"

  project_name           = var.project_name
  deployment_environment = var.deployment_environment
  default_tags           = var.default_tags
  subnet_ids             = module.vpc.private_subnets
  vpc_id                 = module.vpc.vpc_id
}
