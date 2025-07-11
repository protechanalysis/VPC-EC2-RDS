variable "database_name" {
  description = "The name of the database to create when the DB instance is created."
  type        = string
}

variable "engine" {
  description = "The database engine to use."
  type        = string
}

variable "engine_version" {
  description = "The version number of the database engine to use."
  type        = string
}

variable "instance_class" {
  description = "The instance class of the RDS instance."
  type        = string
  default     = "db.t3.micro"
}
# variable "username" {
#   description = "The username for the master DB user."
#   type        = string
#   default     = random_string.username.result
# }
# variable "password" {
#   description = "The password for the master DB user."
#   type        = string
#   default = random_password.password.result
#   sensitive   = true
# }

variable "parameter_group" {
  description = "The name of the DB parameter group to associate with this DB instance."
  type        = string
}

variable "skip_final_snapshot" {
  description = "Specifies whether a final DB snapshot is created before the DB instance is deleted."
  type        = bool
  default     = true
}

variable "vpc_security_group_ids" {
  description = "A list of VPC security groups to associate with the DB instance."
  type        = list(string)
}
variable "subnet_id" {
  description = "The name of the DB subnet group to associate with this DB instance."
  type        = list(string)
}
variable "network_type" {
  description = "The network type of the DB instance."
  type        = string
  default     = "IPV4"
}
variable "publicly_accessible" {
  description = "Specifies whether the DB instance is publicly accessible."
  type        = bool
  default     = true
}

variable "name" {
  description = "The name of the RDS instance."
  type        = string
}

variable "allocated_storage" {
  description = "The amount of storage (in gigabytes) to allocate for the DB instance."
  type        = number
  default     = 10
}