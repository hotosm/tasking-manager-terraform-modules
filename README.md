# tasking-manager-terraform-modules

Terraform modules to get Tasking Manager up and running:

## Supported clouds

Currently supports AWS.

## Modules

1. VPC - Creates VPC, subnet, route tables and gateways
2. Database - Creates RDS instance and associated components
3. Backend - Creates Backend components - containerised deployments to ECS
4. Frontend - Creates S3, CloudFront and associated components
