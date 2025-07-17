resource "aws_db_instance" "dev-rds" {
  allocated_storage      = var.allocated_storage
  db_name                = var.database_name
  engine                 = var.engine
  engine_version         = var.engine_version
  identifier             = var.tags["Name"]
  instance_class         = var.instance_class
  username               = var.username
  password               = var.password
  parameter_group_name   = var.parameter_group
  skip_final_snapshot    = var.skip_final_snapshot
  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.dev-rds-subnet-group.name
  network_type           = var.network_type
  publicly_accessible    = var.publicly_accessible

  tags = var.tags
}

resource "aws_db_subnet_group" "dev-rds-subnet-group" {
  name       = "rds_subnet_group_name"
  subnet_ids = var.subnet_id
}
