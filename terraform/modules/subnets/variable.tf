variable "vpc_id" {}
variable "map_public_ip_on_launch" {
  default = false
}
variable "subnets" {
  description = "List of subnet maps"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}
