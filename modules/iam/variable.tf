variable "name_prefix" {
  type = string
}

variable "codestar_connection_arn" {
  type        = string
  description = "CodeStar connection ARN for GitHub"
}
variable "artifact_bucket" {
  type = string
}
