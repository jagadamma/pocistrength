data "aws_caller_identity" "current" {}

resource "aws_sns_topic" "topic" {
  for_each = var.sns

  name              = each.key
  display_name      = lookup(each.value, "display_name", null)
  kms_master_key_id = aws_kms_key.topic_kms[each.key].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = "SNS:Publish"
      Resource  = "*"
      Condition = {
        StringEquals = {
          "aws:SourceOwner" = data.aws_caller_identity.current.account_id
        }
      }
    }]
  })

  delivery_policy = jsonencode({
    http = {
      defaultHealthyRetryPolicy = {
        numRetries          = 3
        numNoDelayRetries   = 0
        minDelayTarget      = 20
        maxDelayTarget      = 20
        numMinDelayRetries  = 0
        numMaxDelayRetries  = 0
        backoffFunction     = "linear"
      }
      disableSubscriptionOverrides = false
      defaultRequestPolicy = {
        headerContentType = "text/plain; charset=UTF-8"
      }
    }
  })

  tags = merge(
    var.common_tags,
    { Name = each.key }
  )
}
