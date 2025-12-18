resource "aws_kms_key" "topic_kms" {
  for_each = var.sns

  description             = "KMS key for SNS Topic ${each.key}"
  enable_key_rotation     = true
  multi_region            = false
  deletion_window_in_days = lookup(each.value, "kms_deletion_window_in_days", 7)

  lifecycle {
    ignore_changes = [tags]
  }

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = "*" }
      Action    = "kms:*"
      Resource  = "*"
    }]
  })

  tags = merge(
    var.common_tags,
    { Name = "${each.key}-kms" }
  )
}

resource "time_sleep" "wait_for_kms" {
  for_each        = var.sns
  depends_on      = [aws_kms_key.topic_kms]
  create_duration = "30s"
}

resource "aws_kms_alias" "topic_kms" {
  for_each      = var.sns
  name          = "alias/${each.key}"
  target_key_id = aws_kms_key.topic_kms[each.key].key_id
  depends_on    = [time_sleep.wait_for_kms]
}