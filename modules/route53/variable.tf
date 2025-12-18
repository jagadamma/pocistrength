variable "common_tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

variable "hosted_zones" {
  description = "Map of hosted zones to create"
  type = map(object({
    comment       = string
    force_destroy = bool
    private_zone  = bool
  }))
}

variable "records" {
  description = "Map of Route53 records"
  type = map(object({
    zone_name = string
    name      = string
    type      = string
    records = list(string)
    ttl       = optional(number)
    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = bool
    }))
  }))
}

variable "vpc_id" {
  description = "VPC IDs for private hosted zones"
  type        = string
}
