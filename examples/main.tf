module "vpc" {
  source = "../modules/vpc"

  project_name           = var.project_name
  deployment_environment = var.deployment_environment
  default_tags           = var.default_tags
}

module "database" {
  source = "../modules/database"

  rds_opts               = var.rds_opts
  project_name           = var.project_name
  deployment_environment = var.deployment_environment
  default_tags           = var.default_tags
  subnet_ids             = module.vpc.private_subnets
  vpc_id                 = module.vpc.vpc_id
}

module "backend" {
  source = "../modules/backend"

  project_name            = var.project_name
  deployment_environment  = var.deployment_environment
  aws_region              = lookup(var.aws_region, var.deployment_environment)
  vpc_id                  = module.vpc.vpc_id
  database_security_group = module.database.database_security_group_id
  subnets = {
    service      = module.vpc.private_subnets
    loadbalancer = module.vpc.public_subnets
  }

  secrets_store_db_credential_arn = module.database.database_credentials

  secrets_store_credential_names = {
    smtp_connect = join("/",
      [
        "hotosm.org",
        var.project_name,
        var.deployment_environment,
        "smtp-credentials"
      ]
    )
    tm_secret = join("/",
      [
        "hotosm.org",
        var.project_name,
        var.deployment_environment,
        "tm-secret"
      ]
    )
    new_relic_license_key = join("/",
      [
        "hotosm.org",
        "common",
        "newrelic-license-key"
      ]
    )
    oauth2_app_connect = join("/",
      [
        "hotosm.org",
        var.project_name,
        var.deployment_environment,
        "osm-oauth2-app-credentials"
      ]
    )
    sentry_dsn = join("/",
      [
        "hotosm.org",
        var.project_name,
        "common",
        "backend",
        "sentry-dsn"
      ]
    )
    image_upload = join("/",
      [
        "hotosm.org",
        var.project_name,
        var.deployment_environment,
        "image-upload-credentials"
      ]
    )
  }
}
