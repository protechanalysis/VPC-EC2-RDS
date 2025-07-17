variable "vpc_id" {
  description = "VPC ID where the route table will be created"
  type        = string
}

variable "name" {
  description = "Name tag for the route table"
  type        = string
}

variable "type" {
  description = "Type of route table (public or private)"
  type        = string
  validation {
    condition     = contains(["public", "private"], var.type)
    error_message = "Type must be either 'public' or 'private'."
  }
}

variable "route_cidr" {
  description = "CIDR block for the route"
  type        = string
}

variable "gateway_id" {
  description = "ID of the Internet Gateway"
  type        = string
  default     = null
}
variable "tags" {
  description = "A map of tags to add to the route table"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "Map of subnet names to subnet IDs"
  type        = map(string)
}