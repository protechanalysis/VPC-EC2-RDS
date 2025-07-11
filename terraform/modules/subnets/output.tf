output "subnet_ids" {
  description = "Map of subnet names to subnet IDs"
  value = { for subnet in aws_subnet.test_subnet : subnet.tags["Name"] => subnet.id }
}

output "subnets" {
  description = "List of subnet objects"
  value = var.subnets
}