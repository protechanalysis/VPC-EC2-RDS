output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.public_subnet.subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.private_subnet.subnet_ids
}

output "igw_id" {
  description = "ID of the Internet Gateway"
  value       = module.igw.igw_id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = module.public_route_table.route_table_id
}

output "public_route_table_arn" {
  description = "ARN of the public route table"
  value       = module.public_route_table.route_table_arn
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2_instance.instance_id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = module.group_security
}

output "id" {
  description = "ID of the security group"
  value       = module.group_security.id
}

output "name" {
  description = "Name of the security group"
  value       = module.group_security.name
}

output "arn" {
  description = "ARN of the security group"
  value       = module.group_security.arn
}