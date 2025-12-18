resource "aws_secretsmanager_secret" "secrets" {
  for_each = { for secret in var.secrets_list : secret.name => secret }

  name                     = each.value.name
  description              = each.value.description
  kms_key_id               = aws_kms_key.secrets_kms_key[each.key].arn
  recovery_window_in_days  = 7

  tags = merge(
    var.common_tags,
    {
      Name        = each.value.name
    }
  )
}
