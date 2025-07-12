output "database_name" {
  value = aws_db_instance.test-rds.db_name
}

output "subnet" {
  value = aws_db_subnet_group.test-rds-subnet-group.name
}

output "rds_endpoint" {
  value = aws_db_instance.test-rds.endpoint
}

output "password" {
  value = aws_db_instance.test-rds.password
  # sensitive = true
}

output "username" {
  value = aws_db_instance.test-rds.username
  # sensitive = true
}