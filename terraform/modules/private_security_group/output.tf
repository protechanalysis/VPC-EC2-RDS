# filepath: c:\Users\Dell\Data Engineering\personal project\Infrastructure\resources\modules\security_group\outputs.tf
output "id" {
  description = "ID of the security group"
  value       = aws_security_group.private_sg.id
}

output "name" {
  description = "Name of the security group"
  value       = aws_security_group.private_sg.name
}

output "arn" {
  description = "ARN of the security group"
  value       = aws_security_group.private_sg.arn
}