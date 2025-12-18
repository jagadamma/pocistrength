variable "distributions" {
  description = "Map of CloudFront distributions"
  type = map(object({
    domain_name       = string            # example: app.example.com
    hosted_zone_id    = string            # Route53 hosted zone
    origin_path       = optional(string)  # example: /static
    waf_acl_arn       = optional(string)  # for WAF protection
  }))
}



variable "common_tags" {
  type        = map(string)
  default     = {}
}