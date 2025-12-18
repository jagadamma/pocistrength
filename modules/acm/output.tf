output "single_certificate_arns" {
  description = "ARNs of all individual certificates"
  value       = { for d, c in aws_acm_certificate.single : d => c.arn }
}

output "multi_certificate_arn" {
  description = "ARN of SAN certificate"
  value       = aws_acm_certificate.multi.arn
}
