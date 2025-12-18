output "cloudfront_domains" {
  value = {
    for k, v in aws_cloudfront_distribution.distribution :
    k => v.domain_name
  }
}

output "buckets" {
  value = {
    for k, v in aws_s3_bucket.cf_bucket :
    k => v.id
  }
}
