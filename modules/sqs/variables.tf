# SQS Module Variables

variable "sqs_queues" {
  description = "SQS queues configuration"
  type = map(object({
    name = string
    message_retention_seconds = number
    visibility_timeout_seconds = number
    max_message_size = number
    delay_seconds = number
    receive_wait_time_seconds = number
    sqs_managed_sse_enabled = bool
  }))
}

variable "common_tags" {
  type        = map(string)
  default     = {}
}