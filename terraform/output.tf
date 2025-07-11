output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.public_subnet.subnet_ids # Changed from public_subnets to public_subnet
}

output "private_subnet_ids" {
  value = module.private_subnet.subnet_ids # Changed from private_subnets to private_subnet
}

output "igw_id" {
  value = module.igw.igw_id
}

output "public_route_table_id" {
  value = module.public_route_table.route_table_id
}

output "public_route_table_arn" {
  value = module.public_route_table.route_table_arn
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