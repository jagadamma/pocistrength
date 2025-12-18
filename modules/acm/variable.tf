variable "domains" {
  type = list(string)
}

variable "multi_domain_cert" {
  type = object({
    domain_name               = string
    subject_alternative_names = list(string)
  })
}

variable "validation_method" {
  type    = string
  default = "DNS"
}

variable "hosted_zone_id" {
  type = string
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}