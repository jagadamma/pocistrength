variable "sns" {
  description = "SNS topics with config"
  type = map(object({
    display_name                = optional(string)
    kms_deletion_window_in_days = optional(number)
    subscriptions = optional(list(object({
      protocol = string
      endpoint = string
    })))
  }))
}

variable "common_tags" {
  type        = map(string)
  description = "Default common tags"
}
