output "username" {
  description = "RDS Username stored in SSM Parameter Store"
  value       = aws_ssm_parameter.username.value
  
}

output "password" {
  description = "RDS Password stored in SSM Parameter Store"
  value       = aws_ssm_parameter.password.value
  sensitive   = true
}