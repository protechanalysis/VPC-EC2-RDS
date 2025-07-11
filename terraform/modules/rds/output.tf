output "database_name" {
  value = aws_db_instance.test-rds.db_name
}

output "username" {
  value = aws_db_instance.test-rds.username
}

output "subnet" {
  value = aws_db_subnet_group.test-rds-subnet-group.name
}