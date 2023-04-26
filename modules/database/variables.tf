variable "project_name" {
  description = "Name of the project"

  type    = string
  default = "tasking-manager"
}

variable "deployment_environment" {
  description = "Flavour or deployment environment"

  type    = string
  default = "dev"

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

variable "vpc_id" {
  description = "VPC ID to host resources"
  type        = string
}

variable "rds_opts" {
  description = "RDS Options"

  type = map(string)
  default = {
    instance_class = "db.t4g.large"
    multi_az       = false
  }
}

variable "subnet_ids" {
  description = "List of Subnet IDs - preferably private subnets - to host the RDS instance in"

  type = list(string)
}

variable "database" {
  description = "PostgreSQL parameters"
  type        = map(string)

  default = {
    name           = "taskingmanager"
    admin_user     = "hotdba"
    admin_password = "MyGreatSecret"
    engine_version = 13
  }
}

variable "storage" {
  description = "Storage parameters"
  type        = map(string)

  default = {
    type            = "gp2"
    min_capacity    = "1000"
    max_capacity    = "5000"
    throughput_MBps = "125"
    iops            = "3000"
  }
}

variable "publicly_accessible" {
  type = bool

  default = false
}

variable "backup" {
  description = "Database backups and snapshots"
  type        = map(string)

  default = {
    retention_days            = 7
    skip_final_snapshot       = true
    final_snapshot_identifier = "test"
  }
}

variable "monitoring" {
  description = "Database monitoring and logging"
  type        = map(string)

  default = {
    interval_sec                 = 0 // Allowed values -  0,1,5,10,15,30,60
    performance_insights_enabled = true
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

variable "domain_tld" {
  description = "Organisation domain and top level domain"
  type        = map(string)

  default = {
    domain = "hotosm"
    tld    = "org"
  }
}
