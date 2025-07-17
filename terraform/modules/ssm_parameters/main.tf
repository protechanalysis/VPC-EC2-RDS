resource "random_string" "username" {
  length  = 10
  special = false
  numeric = false
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "#$&_-"
}

resource "aws_ssm_parameter" "username" {
  name        = "db_username"
  description = "RDS Username"
  type        = "String"
  value       = random_string.username.result
}

resource "aws_ssm_parameter" "password" {
  name        = "db_password"
  description = "RDS Password"
  type        = "SecureString"
  value       = random_password.password.result
}

resource "aws_ssm_parameter" "db_host" {
  name  = "db_host"
  type  = "String"
  value = var.db_host
}

resource "aws_ssm_parameter" "db_name" {
  name  = "db_name"
  type  = "String"
  value = var.db_name
}
