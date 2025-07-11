output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web-test.id
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.web-test.private_ip
}

# output "security_group_id" {
#   description = "ID of the security group"
#   value       = aws_security_group.instance.id
# }