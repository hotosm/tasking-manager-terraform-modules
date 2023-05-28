/*
output "database_instance_id" {
  value = aws_db_instance.database.id
}

output "subnet_group_id" {
  value = aws_db_subnet_group.database.id
}

output "database_security_group_id" {
  value = aws_security_group.database.id
}

output "db_parameter_group_id" {
  value = aws_db_parameter_group.baseline.id
}

output "database_credentials" {
  value = aws_secretsmanager_secret_version.db-credentials.arn
}

output "database_connection_host" {
  value = aws_db_instance.database.address
}

output "database_connection_port" {
  value = aws_db_instance.database.port
}

output "database_name" {
  value = aws_db_instance.database.db_name
}

output "database_connection_user" {
  value = aws_db_instance.database.username
}
*/

output "database_instance_id" {
  value = aws_rds_cluster.database.id
}

output "subnet_group_id" {
  value = aws_db_subnet_group.database.id
}

output "database_security_group_id" {
  value = aws_security_group.database.id
}

output "db_parameter_group_id" {
  value = aws_db_parameter_group.baseline.id
}

output "database_credentials" {
  value = aws_secretsmanager_secret_version.db-credentials.arn
}

output "database_connection_host" {
  value = aws_rds_cluster.database.endpoint
}

output "database_connection_port" {
  value = aws_rds_cluster.database.port
}

output "database_name" {
  value = aws_rds_cluster.database.database_name
}

output "database_connection_user" {
  value = aws_rds_cluster.database.master_username
}
