resource "aws_kms_key" "secrets_kms_key" {
  for_each = { for secret in var.secrets_list : secret.name => secret }

  description             = "KMS key for secret ${each.key}"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${each.key}-kms"
    }
  )
}

resource "time_sleep" "wait_for_kms_secret" {
  for_each        = { for secret in var.secrets_list : secret.name => secret }
  depends_on      = [aws_kms_key.secrets_kms_key]
  create_duration = "60s"
}

resource "aws_kms_alias" "secrets_kms_alias" {
  for_each      = { for secret in var.secrets_list : secret.name => secret }
  name          = "alias/${each.key}-kms"
  target_key_id = aws_kms_key.secrets_kms_key[each.key].key_id
  depends_on    = [time_sleep.wait_for_kms_secret]
}
