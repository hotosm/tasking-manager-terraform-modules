data "aws_iam_policy_document" "db-monitor-sts" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "db-monitor" {
  name = "AmazonRDSEnhancedMonitoringRole"
}

resource "aws_iam_role" "db-monitor" {
  description = "Role to enable Enhanced RDS Monitoring"

  assume_role_policy  = data.aws_iam_policy_document.db-monitor-sts.json
  managed_policy_arns = [data.aws_iam_policy.db-monitor.arn]

  name_prefix = "db-monitoring"
  path = join("", [
    "/",
    lookup(var.domain_tld, "domain"),
    "/",
    replace(var.project_name, "-", ""),
    "/",
    var.deployment_environment,
    "/"
  ])
}

resource "aws_db_subnet_group" "database" {
  description = "Subnet group to host the database in"

  name = join("-", [var.project_name, var.deployment_environment])

  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "database" {
  description = "Security group to attach to the Database instance"

  name_prefix = join("-", [var.project_name, var.deployment_environment])
  vpc_id      = var.vpc_id

}

resource "aws_db_parameter_group" "baseline" {
  name_prefix = join("-", [var.project_name, var.deployment_environment])
  family      = join("", ["postgres", lookup(var.database, "engine_version")])
  description = "AWS RDS PostgreSQL parameter set"
}

resource "random_password" "database" {
  length  = lookup(var.database, "password_length")
  special = false
}

resource "aws_db_instance" "database" {
  identifier = join("-", [var.project_name, var.deployment_environment])

  // RDS instance options
  instance_class       = lookup(var.rds_opts, "instance_class")
  multi_az             = lookup(var.rds_opts, "multi_az")
  parameter_group_name = aws_db_parameter_group.baseline.name

  // Engine options
  engine         = "postgres"
  engine_version = lookup(var.database, "engine_version")

  // Data backup options
  backup_retention_period   = lookup(var.backup, "retention_days")
  final_snapshot_identifier = lookup(var.backup, "final_snapshot_identifier")
  copy_tags_to_snapshot     = true
  delete_automated_backups  = false

  // Networking (and security) options
  db_subnet_group_name   = aws_db_subnet_group.database.name
  network_type           = "DUAL"
  publicly_accessible    = var.publicly_accessible
  vpc_security_group_ids = [aws_security_group.database.id]

  // Storage Options
  max_allocated_storage = lookup(var.storage, "max_capacity")
  allocated_storage     = lookup(var.storage, "min_capacity")
  storage_type          = lookup(var.storage, "type")
  storage_throughput    = lookup(var.storage, "type") == "gp3" ? lookup(var.storage, "throughput_MBps") : null
  iops                  = lookup(var.storage, "type") == "gp3" ? lookup(var.storage, "iops") : null

  // Monitoring options
  monitoring_interval          = lookup(var.monitoring, "interval_sec")
  monitoring_role_arn          = lookup(var.monitoring, "interval_sec") == "0" ? null : aws_iam_role.db-monitor.arn
  performance_insights_enabled = lookup(var.monitoring, "performance_insights_enabled")

  // Database options
  db_name  = lookup(var.database, "name")
  username = lookup(var.database, "admin_user")
  password = random_password.database.result
}
