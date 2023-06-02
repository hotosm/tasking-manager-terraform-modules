data "aws_route53_zone" "primary" {
  name = var.domain_name_dot_tld
}

data "aws_secretsmanager_secret" "oauth2_creds" {
  name = lookup(var.secrets_store_credential_names, "oauth2_app_connect")
}

data "aws_secretsmanager_secret_version" "oauth2_creds" {
  secret_id = data.aws_secretsmanager_secret.oauth2_creds.id
}

locals {
  _oauth2 = data.aws_secretsmanager_secret_version.oauth2_creds.secret_string
  oauth2  = jsondecode(local._oauth2)
  oauth2_vars = {
    REACT_APP_OSM_CLIENT_ID     = local.oauth2["CLIENT_ID"]
    REACT_APP_OSM_CLIENT_SECRET = local.oauth2["CLIENT_SECRET"]
    REACT_APP_OSM_REDIRECT_URL  = local.oauth2["REDIRECT_URI"]
  }
}

resource "aws_amplify_app" "frontend" {
  name        = join("-", [var.project_name, var.deployment_environment])
  description = "Tasking Manager Frontend App"
  platform    = "WEB"

  repository   = lookup(var.repository, "uri")
  access_token = var.access_token

  enable_branch_auto_build    = true
  enable_auto_branch_creation = false

  build_spec = <<-EOT
  version: 1
  applications:
    - frontend:
        phases:
          preBuild:
            commands:
              - yarn install
          build:
            commands:
              - yarn run build
        artifacts:
          baseDirectory: build
          files:
            - '**/*'
        cache:
          paths:
            - node_modules/**/*
      appRoot: frontend
  EOT
}

resource "aws_amplify_branch" "selected" {
  description       = "Branch of Tasking Manager to deploy"
  app_id            = aws_amplify_app.frontend.id
  branch_name       = lookup(var.repository, "branch")
  display_name      = lookup(var.repository, "branch_display_name")
  enable_auto_build = true

  environment_variables = merge(
    var.amplify_config_environment_variables,
    local.oauth2_vars,
    var.environment_variables,
    { REACT_APP_ENVIRONMENT = var.deployment_environment }
  )

  framework = "React"
  stage     = lookup(var.repository, "branch_deployment_stage")
}

resource "aws_amplify_domain_association" "primary" {
  app_id      = aws_amplify_app.frontend.id
  domain_name = var.domain_name_dot_tld

  sub_domain {
    branch_name = aws_amplify_branch.selected.branch_name
    prefix      = var.sub_domain_prefix
  }
}


