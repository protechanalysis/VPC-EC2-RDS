module "vpc" {
  source               = "./modules/vpc"
  name                 = "custom-vpc"
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

module "public_subnet" {
  source = "./modules/subnets"

  vpc_id                  = module.vpc.vpc_id
  map_public_ip_on_launch = true

  subnets = [
    {
      name = "public-1"
      cidr = "10.0.1.0/24"
      az   = "us-east-1a"
    },
    {
      name = "public-2"
      cidr = "10.0.2.0/24"
      az   = "us-east-1b"
    }
  ]
}

module "private_subnet" {
  source = "./modules/subnets"

  vpc_id                  = module.vpc.vpc_id
  map_public_ip_on_launch = false

  subnets = [
    {
      name = "private-1"
      cidr = "10.0.3.0/24"
      az   = "us-east-1a"
    },

    {
      name = "private-2"
      cidr = "10.0.4.0/24"
      az   = "us-east-1b"

    }
  ]
}

module "igw" {
  source = "./modules/internet_gateway"

  vpc_id = module.vpc.vpc_id
  name   = "vpc-igw"
}

module "public_route_table" {
  source = "./modules/routes_tables"

  vpc_id     = module.vpc.vpc_id
  name       = "public-rt"
  type       = "public"
  route_cidr = "0.0.0.0/0"
  gateway_id = module.igw.igw_id
  subnet_ids = module.public_subnet.subnet_ids

}

module "group_security" {
  source      = "./modules/public_security_group"
  name        = "bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP traffic"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow SSH access"
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]

  tags = {
    Environment = "dev"
    Project     = "demo"
  }
}

module "private_security_group" {
  source = "./modules/private_security_group"
  name   = "private-ec2-sg"
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
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]

  tags = {
    Environment = "dev"
    Project     = "demo"
  }
}

module "ec2_instance" {
  source                  = "./modules/bastion"
  name                    = "bastion"
  instance_type           = "t3.micro"
  vpc_id                  = module.vpc.vpc_id
  public_subnet_id        = module.public_subnet.subnet_ids["public-1"]
  security_group_id       = [module.group_security.id]
  ssh_allowed_cidr_blocks = ["0.0.0.0/0"]
  user_data = templatefile("${path.module}/modules/bastion/scripts/bootstraps.sh.tpl", {
    db_host = module.rds.rds_endpoint,
    db_user = module.rds.username,
    db_pass = module.rds.password,
    db_name = module.rds.database_name
  })
  depends_on = [module.rds, module.group_security]


  tags = {
    Environment = "dev"
    Project     = "demo"
  }
}

module "rds" {
  source                 = "./modules/rds"
  database_name          = "testdb"
  engine                 = "mysql"
  engine_version         = "8.0"
  parameter_group        = "default.mysql8.0"
  vpc_security_group_ids = [module.private_security_group.id]
  subnet_id              = [module.private_subnet.subnet_ids["private-1"], module.private_subnet.subnet_ids["private-2"]] # Use the first public subnet for RDS
  name                   = "rds-instance-test"
  depends_on             = [module.policy]
}

module "policy" {
  source      = "./modules/iam_policy"
  policy_name = "rds_access_policy"
  user        = "protectorate"
}