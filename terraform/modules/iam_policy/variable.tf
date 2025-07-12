variable "policy_name" {
  description = "Name of the IAM policy"
  type        = string
  default     = "rds_access_policy"
}

variable "user" {
  description = "Name of the already existing IAM user"
  type        = string
}

