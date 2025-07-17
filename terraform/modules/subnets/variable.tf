variable "vpc_id" {
  description = "The VPC ID where subnets will be created"
  type        = string
}

variable "map_public_ip_on_launch" {
  description = "Whether to map public IP on launch"
  type        = bool
  default     = false
}

variable "subnets" {
  description = "List of subnet configurations"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}

variable "tags" {
  description = "Tags to apply to all subnets"
  type        = map(string)
  default     = {}
}