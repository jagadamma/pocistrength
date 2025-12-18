
resource "aws_s3_bucket" "cf_bucket" {
  for_each = var.distributions
  bucket   = "${each.key}-cf-origin-bucket"
}

resource "aws_s3_bucket_public_access_block" "cf_bucket" {
  for_each                = var.distributions
  bucket                  = aws_s3_bucket.cf_bucket[each.key].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_cloudfront_origin_access_control" "oac" {
  for_each                          = var.distributions
  name                              = "${each.key}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


data "aws_iam_policy_document" "bucket_policy" {
  for_each = var.distributions

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = [
      aws_s3_bucket.cf_bucket[each.key].arn,
      "${aws_s3_bucket.cf_bucket[each.key].arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values = [
        aws_cloudfront_distribution.distribution[each.key].arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "cf_bucket_policy" {
  for_each = var.distributions
  bucket   = aws_s3_bucket.cf_bucket[each.key].id
  policy   = data.aws_iam_policy_document.bucket_policy[each.key].json
}