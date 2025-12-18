resource "aws_route53_record" "alias" {
  for_each = var.distributions

  zone_id = each.value.hosted_zone_id
  name    = each.value.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.distribution[each.key].domain_name
    zone_id                = aws_cloudfront_distribution.distribution[each.key].hosted_zone_id
    evaluate_target_health = false
  }
}
