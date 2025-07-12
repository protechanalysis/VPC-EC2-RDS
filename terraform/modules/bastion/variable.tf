variable "public_subnet_id" {
  description = "Subnet ID where NAT Gateway will be launched (must be public)"
  type        = string
}
variable "name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

# variable "key_name" {
#   description = "Name of the SSH key pair"
#   type        = string
# }

variable "ssh_allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to SSH into the instance"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Additional tags for the resources"
  type        = map(string)
  default     = {}
}

variable "security_group_id" {
  description = "ID of the security group to associate with the EC2 instance"
  type        = list(string)
}

variable "user_data" {
  description = "User data script to run on instance launch"
  type        = string
}
