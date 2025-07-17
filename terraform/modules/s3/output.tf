output "vpc_flow_logs_bucket_name" {
  description = "Name of the VPC Flow Logs S3 bucket"
  value       = aws_s3_bucket.vpc_flow_logs.bucket
}

output "vpc_flow_logs_bucket_arn" {
  description = "ARN of the VPC Flow Logs S3 bucket"
  value       = aws_s3_bucket.vpc_flow_logs.arn
}

output "vpc_flow_logs_role_arn" {
  description = "Name of the IAM role for VPC Flow Logs"
  value       = aws_iam_role.vpc_flow_logs_role.arn
  
}