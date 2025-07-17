data "aws_availability_zones" "available" {
  state = "available"
}

# Local values for more dynamic configuration
locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  public_subnets = [
    for i, az in local.azs : {
      name = "public-${i + 1}"
      cidr = "10.0.${i + 1}.0/24"
      az   = az
    }
  ]

  private_subnets = [
    for i, az in local.azs : {
      name = "private-${i + 1}"
      cidr = "10.0.${i + 3}.0/24"
      az   = az
    }
  ]

  bucket              = var.bucket_name
  name                = var.name
  region              = var.region
  allowed_cidr_blocks = var.allowed_cidr_blocks
  key_name            = var.keypair

  # Common tags to be applied to all resources
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Application = local.name
  }

  # general tags
  tags = merge(local.common_tags, {
  })
  # Tags for specific resources
  vpc_tags = merge(local.common_tags, {
    Name = "${local.name}-vpc"
    Type = "Network"
  })

  subnet_tags = merge(local.common_tags, {
    Type = "Subnet"
  })

  ec2_tags = merge(local.common_tags, {
    Type   = "Compute"
    Backup = "false"
  })

  rds_tags = merge(local.common_tags, {
    Type = "Database"
  })

  s3_tags = merge(local.common_tags, {
    Type = "Storage"
  })
}