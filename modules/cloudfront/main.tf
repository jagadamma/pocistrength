resource "aws_cloudfront_distribution" "distribution" {
  for_each = var.distributions

  enabled = true
  comment = "CloudFront distribution for ${each.key}"

  aliases = [each.value.domain_name]

  origin {
  domain_name = aws_s3_bucket.cf_bucket[each.key].bucket_regional_domain_name
  origin_id   = "${each.key}-origin"

  origin_path = lookup(each.value, "origin_path", "")

  s3_origin_config {
    origin_access_identity = ""   # REQUIRED by Terraform, IGNORED by CloudFront when OAC is used
  }

  origin_access_control_id = aws_cloudfront_origin_access_control.oac[each.key].id
}


  default_cache_behavior {
    target_origin_id       = "${each.key}-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  web_acl_id = lookup(each.value, "waf_acl_arn", null)
}