variable "environment" {
  type = string
}

#variable "vpcs" {
#  type = list
#}

variable "vpcs" {
  type = list(object({
    name = string
    cidr = string
    tags = optional(map(string))
  }))
}

variable "region" {
  type = string
}

#variable "vpc_flow_logs" {
#  description = "Configuration map for VPC flow logs"
#  type = object({
#    log_destination_type = string  # Must be "s3"
#    traffic_type         = string  # "ACCEPT", "REJECT", or "ALL"
#  })
#}


variable "vpc_flow_logs" {
  description = "Configuration map for VPC flow logs"
  type = object({
    log_destination_type = string
    traffic_type         = string
    log_group_name       = string
    log_retention_days   = number
    environment          = string
  })
}
variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "common_tags" {
  type        = map(string)
  default     = {}
}
