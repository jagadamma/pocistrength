variable "s3bucketslist" {
  description = "List of S3 bucket configurations"
  type = list(object({
    bucket_name   = string
    force_destroy = bool
    versioning    = bool
    public_access = bool
  }))
}

variable "common_tags" {
  type        = map(string)
  default     = {}
}