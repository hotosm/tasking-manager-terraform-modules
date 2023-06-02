terraform {

  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.1.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }

  }
}

provider "aws" {
  region = lookup(var.aws_region, "prod")

  default_tags {
    tags = var.default_tags
  }
}

provider "random" {}
