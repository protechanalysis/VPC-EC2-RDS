variable "vpc_id" {}
variable "tags" {
  description = "Tags for the internet gateway"
  type        = map(string)
  default     = {}
  
}