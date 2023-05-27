variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "tasking-manager"
}

variable "deployment_environment" {
  description = "Flavour or deployment environment"
  type        = string

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
        "test",
      ],
      var.deployment_environment
    )
    error_message = "The deployment_environment string does not conform to allowed values"
  }
}

variable "aws_region" {
  description = "AWS Region in which to put resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for resources to be put in"
  type        = string
}

variable "subnets" {
  description = "Subnet IDs in which to start the service"

  type = map(list(string))

  default = {
    service      = []
    loadbalancer = []
  }
}

variable "database_security_group" {
  description = "ID of the security group shared between the database and service"

  type = string
}

variable "container_image" {
  description = "Container image and tag to use for the backend"

  type = map(string)

  default = {
    uri = "quay.io/hotosm/tasking-manager"
    tag = "develop"
  }
}

variable "base_uri" {
  description = "Base URI of the Application"

  type = map(string)

  default = {
    uri    = "tasks.example.com"
    scheme = "https://"
  }
}

variable "smtp_from_address" {
  description = "Default from address for mails sent out"
  type        = string

  default = "foo@bar.com"
}

variable "ephemeral_storage_gb" {
  description = "How much ephemeral storage is needed by the task?"
  type        = number

  default = 21

  validation {
    condition     = var.ephemeral_storage_gb >= 21 && var.ephemeral_storage_gb <= 200
    error_message = "Value must be between 21 and 200 (inclusive)"
  }
}

variable "container_capacity" {
  description = "Container capacity: CPU and Memory"
  type        = map(string)

  default = {
    cpu       = "256" // Equivalent to 0.25 vCPU
    memory_mb = "512"
  }

  validation {
    condition = contains(
      [
        "256",
        "512",
        "1024",
        "2048",
        "4096",
        "8192",
        "16384"
      ],
      lookup(var.container_capacity, "cpu")
    )
    error_message = "CPU value is invalid; must be one of allowed values"
  }

  validation {
    condition = contains(
      [
        "512",
        "1024",
        "2048",
        "3072",
        "4096",
        "5120",
        "6144",
        "7168",
        "8192",
        "16384",
        "30720"
      ],
      lookup(var.container_capacity, "memory_mb")
    )
    error_message = "Mem value is invalid; must be one of allowed values"
  }

}

variable "container_port" {
  description = "Port on which the backend service is exposed within the container"
  type        = number

  default = 5000
}

variable "container_runtime_architecture" {
  description = "Runtime CPU architecture for the containers"

  type = string

  default = "X86_64"
  validation {
    condition     = contains(["X86_64", "ARM64"], var.container_runtime_architecture)
    error_message = "The architecture must be one of X86_64 , ARM64"
  }
}

variable "log_config" {
  type = map(any)

  default = {
    log_level      = "INFO"
    log_dir        = "/var/log/tasking-manager"
    retention_days = 7
  }

  validation {
    condition = contains(
      [
        "INFO",
        "WARN",
        "ERROR",
        "DEBUG",
        "NOTICE",
        "ALERT",
        "CRIT"
      ],
      lookup(var.log_config, "log_level")
    )
    error_message = "Log level is invalid, it must conform to standards"
  }
}

variable "branding" {
  type        = map(string)
  description = "Branding related stuff"

  default = {
    org_name                  = "Humanitarian OpenStreetMap Team"
    org_code                  = "HOT"
    org_logo_url              = ""
    contact_email             = "noreply@bar.com"
    default_changeset_comment = "#hot-project"
  }
}

variable "secrets_store_db_credential_arn" {
  type        = string
  description = "Name of secrets manager entry that stores database credentials"
}

variable "secrets_store_credential_names" {
  type        = map(string)
  description = "Names of secrets manager entries corresponding to stored credentials"

  default = {
    smtp_connect          = ""
    new_relic_license_key = ""
    sentry_dsn            = ""
    image_upload          = ""
    oauth2_app_connect    = ""
    tm_secret             = ""
  }
}

variable "loadbalancer_ssl_policy" {
  description = "Canned SSL policy provided by AWS for Application loadbalancers defining the cipher suites for TLS negotiations"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "https_certificate_domain_name" {
  description = "Domain name for which HTTPS certificate has been issued / imported on AWS ACM"
  type        = string
  default     = "hotosm.org"
}
