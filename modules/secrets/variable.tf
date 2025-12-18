variable "secrets_list" {
  type = list(object({
    name        = string
    description = optional(string, null)
  }))
}


variable "common_tags" {
  type        = map(string)
  default     = {}
}
