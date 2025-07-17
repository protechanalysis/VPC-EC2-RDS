output "instance_profile_name" {
  description = "Name of the instance profile for EC2"
  value       = aws_iam_instance_profile.ec2_ssm_profile.name
}

output "instance_profile_arn" {
  description = "ARN of the instance profile for EC2"
  value       = aws_iam_instance_profile.ec2_ssm_profile.arn
}

output "role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.ec2_ssm_role.arn
}