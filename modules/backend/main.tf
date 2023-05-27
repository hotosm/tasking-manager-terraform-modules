data "aws_acm_certificate" "issued" {
  domain      = var.https_certificate_domain_name
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_iam_policy_document" "tasks-sts" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "secrets-manager-access" {
  statement {
    actions = ["secretsmanager:GetSecretValue"]

    resources = [
      data.aws_secretsmanager_secret.sentry_dsn.arn,
      data.aws_secretsmanager_secret.image_upload.arn,
      data.aws_secretsmanager_secret.new_relic_license_key.arn,
      data.aws_secretsmanager_secret.tm_secret.arn,
      data.aws_secretsmanager_secret.smtp_connect.arn,
      data.aws_secretsmanager_secret.oauth2_app_connect.arn,
      var.secrets_store_db_credential_arn
    ]
  }
}

data "aws_iam_policy_document" "cloudwatch-logs-access" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      aws_cloudwatch_log_group.tasking-manager.arn,
      join(":", [aws_cloudwatch_log_group.tasking-manager.arn, "log-stream", "*"])
    ]
  }
}

data "aws_secretsmanager_secret" "sentry_dsn" {
  name = lookup(var.secrets_store_credential_names, "sentry_dsn")
}

data "aws_secretsmanager_secret" "image_upload" {
  name = lookup(var.secrets_store_credential_names, "image_upload")
}

data "aws_secretsmanager_secret" "new_relic_license_key" {
  name = lookup(var.secrets_store_credential_names, "new_relic_license_key")
}

data "aws_secretsmanager_secret" "tm_secret" {
  name = lookup(var.secrets_store_credential_names, "tm_secret")
}

data "aws_secretsmanager_secret" "smtp_connect" {
  name = lookup(var.secrets_store_credential_names, "smtp_connect")
}

data "aws_secretsmanager_secret" "oauth2_app_connect" {
  name = lookup(var.secrets_store_credential_names, "oauth2_app_connect")
}

resource "aws_iam_role" "ecs-execution" {
  name_prefix        = join("-", [var.project_name, var.deployment_environment, "backend-task"])
  path        = join("", ["/", "tasking-manager", "/", var.deployment_environment, "/"])

  assume_role_policy = data.aws_iam_policy_document.tasks-sts.json

  inline_policy {
    name   = "access-secrets-manager"
    policy = data.aws_iam_policy_document.secrets-manager-access.json
  }

  inline_policy {
    name   = "access-cloudwatch-logs"
    policy = data.aws_iam_policy_document.cloudwatch-logs-access.json
  }
}

resource "aws_iam_role" "ecs-task" {
  name_prefix        = join("-", [var.project_name, var.deployment_environment, "backend-exec"])
  path        = join("", ["/", "tasking-manager", "/", var.deployment_environment, "/"])

  assume_role_policy = data.aws_iam_policy_document.tasks-sts.json

  inline_policy {
    name   = "access-cloudwatch-logs"
    policy = data.aws_iam_policy_document.cloudwatch-logs-access.json
  }
}

resource "aws_cloudwatch_log_group" "tasking-manager" {
  name              = join("-", [var.project_name, var.deployment_environment])
  retention_in_days = lookup(var.log_config, "retention_days")
}

resource "aws_ecs_cluster" "tasking-manager" {
  name = join("-", [var.project_name, var.deployment_environment])

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "tasking-manager" {
  cluster_name = aws_ecs_cluster.tasking-manager.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = 1
    weight            = 85
  }
}

resource "aws_ecs_task_definition" "tasking-manager-backend" {
  family = join("-", [var.project_name, var.deployment_environment])

  requires_compatibilities = ["FARGATE"]
  cpu                      = lookup(var.container_capacity, "cpu")
  memory                   = lookup(var.container_capacity, "memory_mb")

  execution_role_arn = aws_iam_role.ecs-execution.arn
  task_role_arn      = aws_iam_role.ecs-task.arn

  network_mode = "awsvpc"

  ephemeral_storage {
    size_in_gib = var.ephemeral_storage_gb
  }

  // TODO: Add volume configuration
  //  volume {
  //    docker_volume_configuration {
  //      scope = "task"
  //      labels = {
  //        a = "b"
  //        c = "d"
  //      }
  //    }
  //
  //    efs_volume_configuration {
  //      file_system_id = "aws_efs_filesystem.name.id"
  //      root_directory = "/foo"
  //    }
  //  }

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = var.container_runtime_architecture
  }

  container_definitions = jsonencode([
    {
      name  = "backend"
      image = join(":", [lookup(var.container_image, "uri"), lookup(var.container_image, "tag")])

      //    environmentFiles = [
      //      {
      //        type  = "s3"
      //        value = "s3-object-arn"
      //      }
      //    ]

      environment = [
        {
          name  = "deployment_environment"
          value = var.deployment_environment
        },
        {
          name  = "TM_APP_BASE_URL"
          value = lookup(var.base_uri, "uri")
        },
        {
          name  = "TM_ENVIRONMENT"
          value = var.deployment_environment
        },
        {
          name  = "TM_DEFAULT_CHANGESET_COMMENT"
          value = lookup(var.branding, "default_changeset_comment")
        },
        {
          name  = "TM_EMAIL_FROM_ADDRESS"
          value = var.smtp_from_address
        },
        {
          name  = "TM_EMAIL_CONTACT_ADDRESS"
          value = lookup(var.branding, "contact_email")
        },
        {
          name  = "TM_LOG_LEVEL"
          value = lookup(var.log_config, "log_level")
        },
        {
          name  = "TM_ORG_NAME"
          value = lookup(var.branding, "org_name")
        },
        {
          name  = "TM_ORG_CODE"
          value = lookup(var.branding, "org_code")
        },
        {
          name  = "TM_ORG_LOGO"
          value = lookup(var.branding, "org_logo_url")
        },
        {
          name  = "NEW_RELIC_ENVIRONMENT"
          value = var.deployment_environment
        }
      ]

      essential = true

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.tasking-manager.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = join("-", [var.deployment_environment, "backend"])
        }
      }

      portMappings = [
        {
          name          = "backend"
          containerPort = var.container_port
          protocol      = "tcp"
          appProtocol   = "http" // Or "http2" or "grpc"
        }
      ]

      secrets = [
        {
          name      = "TM_DB_CONNECT_PARAM_JSON"
          valueFrom = var.secrets_store_db_credential_arn
        },
        {
          name      = "OAUTH2_APP_CREDENTIALS"
          valueFrom = data.aws_secretsmanager_secret.oauth2_app_connect.arn
        },
        {
          name      = "TM_SECRET"
          valueFrom = data.aws_secretsmanager_secret.tm_secret.arn
        },
        {
          name      = "SMTP_CREDENTIALS"
          valueFrom = data.aws_secretsmanager_secret.smtp_connect.arn
        },
        {
          name      = "NEW_RELIC_LICENSE_KEY"
          valueFrom = data.aws_secretsmanager_secret.new_relic_license_key.arn
        },
        {
          name      = "TM_SENTRY_BACKEND_DSN"
          valueFrom = data.aws_secretsmanager_secret.sentry_dsn.arn
        },
        {
          name      = "IMAGE_UPLOAD_CREDENTIALS"
          valueFrom = data.aws_secretsmanager_secret.image_upload.arn
        },
      ]

      startTimeout = 15
      stopTimeout  = 15

    }
  ])
}

resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name                = "tm-backend-high-cpu"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "This metric monitors ECS CPU utilisation"
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "mem" {
  alarm_name                = "tm-backend-high-mem"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "MemoryUtilization"
  namespace                 = "AWS/ECS"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "This metric monitors ECS CPU utilisation"
  insufficient_data_actions = []
}

resource "aws_security_group" "backend-to-loadbalancer" {
  description = "Security group to attach to the backend containers"

  name_prefix = join("-", [var.project_name, var.deployment_environment])
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow from security groups"
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_ecs_service" "backend" {
  name    = join("-", [var.project_name, var.deployment_environment])
  cluster = aws_ecs_cluster.tasking-manager.arn

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"
    container_port   = var.container_port
  }

  alarms {
    alarm_names = [
      aws_cloudwatch_metric_alarm.cpu.alarm_name,
      aws_cloudwatch_metric_alarm.mem.alarm_name
    ]
    enable   = true
    rollback = false
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = 1
    weight            = 85
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = 0
    weight            = 15
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 50
  desired_count                      = 1
  enable_ecs_managed_tags            = true
  force_new_deployment               = true
  health_check_grace_period_seconds  = 10

  network_configuration {
    subnets = lookup(var.subnets, "service")
    security_groups = [
      aws_security_group.backend-to-loadbalancer.id,
      var.database_security_group
    ]
  }

  propagate_tags        = "SERVICE" // OR TASK_DEFINITION
  scheduling_strategy   = "REPLICA"
  task_definition       = aws_ecs_task_definition.tasking-manager-backend.arn
  wait_for_steady_state = true
}

resource "aws_lb" "backend" {
  name               = join("-", [var.project_name, var.deployment_environment])
  internal           = false
  ip_address_type    = "dualstack"
  load_balancer_type = "application"

  security_groups = [aws_security_group.backend-to-loadbalancer.id]

  subnets = lookup(var.subnets, "loadbalancer")
}

resource "aws_lb_target_group" "backend" {
  name        = join("-", [var.project_name, var.deployment_environment])
  target_type = "ip"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    enabled  = true
    matcher  = "200-399"
    path     = "/api/v2/system/heartbeat"
    protocol = "HTTP"
    port     = var.container_port

    interval            = 15
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

// resource "aws_lb_target_group_attachment" "backend" {
//   target_group_arn  = aws_lb_target_group.backend.arn
//   target_id         = aws_lb.backend.arn
//   port              = 80
//   availability_zone = "all"
// }

resource "aws_lb_listener" "backend-plain" {
  load_balancer_arn = aws_lb.backend.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "backend-secure" {
  load_balancer_arn = aws_lb.backend.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.loadbalancer_ssl_policy
  certificate_arn   = data.aws_acm_certificate.issued.arn

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.backend.arn
        weight = 100
      }
    }
  }
}

