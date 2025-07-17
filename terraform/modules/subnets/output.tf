output "subnet_ids" {
  description = "Map of subnet names to subnet IDs"
  value       = { for k, v in aws_subnet.dev_subnet : k => v.id }
}

output "subnet_arns" {
  description = "Map of subnet names to subnet ARNs"
  value       = { for k, v in aws_subnet.dev_subnet : k => v.arn }
}