output "sns_topic_arns" {
  value = { for k, v in aws_sns_topic.topic : k => v.arn }
}

output "kms_key_arns" {
  value = { for k, v in aws_kms_key.topic_kms : k => v.arn }
}
