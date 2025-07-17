output "database_name" {
  value = aws_db_instance.dev-rds.db_name
}

output "subnet" {
  value = aws_db_subnet_group.dev-rds-subnet-group.name
}

output "rds_endpoint" {
  value = aws_db_instance.dev-rds.endpoint
}