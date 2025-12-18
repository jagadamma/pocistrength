
resource "aws_kms_key" "kms" {
  for_each = var.rds

  description             = "KMS key for RDS ${each.key}"
  enable_key_rotation     = true
  multi_region            = false
  deletion_window_in_days = 7

lifecycle {
  ignore_changes = [tags, tags_all]
}

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": { "AWS": "*" },
      "Action": "kms:*",
      "Resource": "*"
    }]
  })

  tags = merge(
    var.common_tags,
    {
      Name = each.value.kms_key_name
    }
  )
}

resource "time_sleep" "wait_for_kms" {
  for_each        = var.rds
  depends_on      = [aws_kms_key.kms]
  create_duration = "60s"
}

resource "aws_kms_alias" "kms" {
  for_each      = var.rds
  name          = "alias/${each.value.kms_key_name}"
  target_key_id = aws_kms_key.kms[each.key].key_id
  depends_on    = [time_sleep.wait_for_kms]
}