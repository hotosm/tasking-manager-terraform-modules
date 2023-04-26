output "database_id" {
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

