output "s3_bucket_names" {
  description = "List of S3 bucket names"
  value       = [for b in aws_s3_bucket.common_s3 : b.bucket]
}

output "s3_bucket_arns" {
  description = "List of S3 bucket ARNs"
  value       = [for b in aws_s3_bucket.common_s3 : b.arn]
}