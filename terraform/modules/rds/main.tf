resource "random_string" "username" {
  length  = 10
  special = false
  numeric = false
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!_$&/"
}

resource "aws_ssm_parameter" "name" {
  name        = "rds_username"
  description = "RDS Username"
  type        = "String"
  value       = random_string.username.result
}

resource "aws_ssm_parameter" "password" {
  name        = "rds_password"
  description = "RDS Password"
  type        = "SecureString"
  value       = random_password.password.result
}

resource "aws_db_subnet_group" "test-rds-subnet-group" {
  name       = "rds_subnet_group_name"
  subnet_ids = var.subnet_id
}


resource "aws_db_instance" "test-rds" {
  allocated_storage      = var.allocated_storage
  db_name                = var.database_name
  engine                 = var.engine
  engine_version         = var.engine_version
  identifier             = var.name
  instance_class         = var.instance_class
  username               = aws_ssm_parameter.name.value
  password               = aws_ssm_parameter.password.value
  parameter_group_name   = var.parameter_group
  skip_final_snapshot    = var.skip_final_snapshot
  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.test-rds-subnet-group.name
  network_type           = var.network_type
  publicly_accessible    = var.publicly_accessible

  tags = {
    Name = var.name
  }
}