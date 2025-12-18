
# Get AWS Account ID (for queue owner policy)
data "aws_caller_identity" "current" {}


resource "aws_sqs_queue" "queue" {
  for_each = var.sqs_queues
  
  name                         = each.value.name
  max_message_size             = each.value.max_message_size
  message_retention_seconds    = each.value.message_retention_seconds
  visibility_timeout_seconds   = each.value.visibility_timeout_seconds
  delay_seconds                = each.value.delay_seconds
  receive_wait_time_seconds    = each.value.receive_wait_time_seconds
  
  sqs_managed_sse_enabled      = each.value.sqs_managed_sse_enabled
  
  tags = merge(
    var.common_tags,
    {
      Name = each.value.name
    }
  )
}

resource "aws_sqs_queue_policy" "owner_policy" {
  for_each  = aws_sqs_queue.queue

  queue_url = each.value.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "QueueOwnerPolicy"

    Statement = [
      {
        Sid    = "QueueOwnerFullAccess"
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }

        Action   = "SQS:*"
        Resource = each.value.arn
      }
    ]
  })
}
