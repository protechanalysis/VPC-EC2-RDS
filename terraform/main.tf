module "object_storage" {
  source      = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/s3_bucket/vpc_flow_log_s3?ref=v1.0.0"
  bucket_name = local.bucket
  tags = merge(local.s3_tags, {
    Name = "${local.name}-s3-bucket"
  })
}

module "vpc" {
  source          = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/vpc?ref=v1.0.0"
  name            = "${local.name}-vpc"
  cidr_block      = "10.0.0.0/16"
  log_destination = module.object_storage.vpc_flow_logs_bucket_arn
  tags            = local.vpc_tags
}

module "public_subnet" {
  source                  = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/subnets?ref=v1.0.0"
  vpc_id                  = module.vpc.vpc_id
  map_public_ip_on_launch = true
  subnets                 = local.public_subnets
  tags = merge(local.subnet_tags, {
    Tier = "Public"
  })
}

module "private_subnet" {
  source                  = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/subnets?ref=v1.0.0"
  vpc_id                  = module.vpc.vpc_id
  map_public_ip_on_launch = false
  subnets                 = local.private_subnets
  tags = merge(local.subnet_tags, {
    Tier = "Private"
  })
}

module "igw" {
  source = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/internet_gateway?ref=v1.0.0"
  vpc_id = module.vpc.vpc_id
  tags = merge(local.common_tags, {
    Name = "${local.name}-vpc-igw"
    Type = "InternetGateway"
  })
}

module "public_route_table" {
  source     = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/routes_tables?ref=v1.0.0"
  vpc_id     = module.vpc.vpc_id
  name       = "public-rt"
  type       = "public"
  route_cidr = local.allowed_cidr_blocks
  gateway_id = module.igw.igw_id
  subnet_ids = module.public_subnet.subnet_ids
  tags = merge(local.common_tags, {
    Name = "${local.name}-public-rt"
    Type = "Public"
  })
}

module "public_security_group" {
  source      = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/security_group?ref=v1.0.0"
  name        = "${local.name}-sg"
  description = "Security group for bastion host"
  vpc_id      = module.vpc.vpc_id
  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [local.allowed_cidr_blocks]
      description = "Allow HTTP traffic"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [local.allowed_cidr_blocks]
      description = "Allow SSH access"
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [local.allowed_cidr_blocks]
      description = "Allow all outbound traffic"
    }
  ]
  tags = merge(local.common_tags, {
    Name = "${local.name}-sg"
    Type = "SecurityGroup"
  })
}

module "private_security_group" {
  source = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/security_group?ref=v1.0.0"
  name   = "${local.name}-private-sg"
  vpc_id = module.vpc.vpc_id
  ingress_rules = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "Allow MySQL access from VPC"
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [local.allowed_cidr_blocks]
      description = "Allow all outbound traffic"
    }
  ]
  tags = merge(local.common_tags, {
    Type = "SecurityGroup"
  })
}


module "rds" {
  source                 = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/rds?ref=v1.0.0"
  database_name          = "${local.name}_db"
  password               = module.ssm_parameters.password
  username               = module.ssm_parameters.username
  engine                 = "mysql"
  engine_version         = "8.0"
  parameter_group        = "default.mysql8.0"
  vpc_security_group_ids = [module.private_security_group.id]
  subnet_id              = [module.private_subnet.subnet_ids["private-1"], module.private_subnet.subnet_ids["private-2"]]
  tags = merge(local.rds_tags, {
    Name = "${local.name}-rds-instance"
  })
}

module "ssm_parameters" {
  source  = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/ssm_parameters?ref=v1.0.0"
  db_host = split(":", module.rds.rds_endpoint)[0]
  db_name = module.rds.database_name
}

module "role" {
  source = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/iam_role/ssm_ec2/?ref=v1.0.0"
  name   = "${local.name}-ec2-ssm-role"
  tags   = local.ec2_tags
}

module "ec2_instance" {
  source                  = "git::https://github.com/protechanalysis/terraform-aws-module.git//aws_modules/instance?ref=v1.0.0"
  instance_type           = "t3.micro"
  vpc_id                  = module.vpc.vpc_id
  public_subnet_id        = module.public_subnet.subnet_ids["public-1"]
  instance_profile_name   = module.role.instance_profile_name
  key_pair                = local.key_name
  security_group_id       = [module.public_security_group.id]
  ssh_allowed_cidr_blocks = [local.allowed_cidr_blocks]
  user_data               = file("../scripts/bootstraps.sh")
  depends_on              = [module.rds, module.public_security_group, module.object_storage]
  tags = merge(local.ec2_tags, {
    Name = "${local.name}-instance"
  })

}
