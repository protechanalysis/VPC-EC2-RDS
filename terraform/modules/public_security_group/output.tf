# filepath: c:\Users\Dell\Data Engineering\personal project\Infrastructure\resources\modules\security_group\outputs.tf
output "id" {
  description = "ID of the security group"
  value       = aws_security_group.bastion_sg.id
}

output "name" {
  description = "Name of the security group"
  value       = aws_security_group.bastion_sg.name
}

output "arn" {
  description = "ARN of the security group"
  value       = aws_security_group.bastion_sg.arn
}