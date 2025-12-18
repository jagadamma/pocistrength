
resource "aws_route53_zone" "zones" {
  for_each = var.hosted_zones

  name          = each.key
  comment       = try(each.value.comment, null)
  force_destroy = try(each.value.force_destroy, false)

  # If private_zone = true, attach VPCs
  dynamic "vpc" {
  for_each = try(each.value.private_zone, false) ? (
    length(try(each.value.vpc_ids, [])) > 0 ?
    each.value.vpc_ids :
    [var.vpc_id]
  ) : []

  content {
    vpc_id = vpc.value
  }
}

  tags = merge(
    var.common_tags,
    { Name = each.key }
  )
}

resource "aws_route53_record" "records" {
  for_each = var.records

  zone_id = aws_route53_zone.zones[each.value.zone_name].zone_id
  name    = each.value.name
  type    = each.value.type

  records = each.value.alias == null ? try(each.value.records, []) : null
  ttl     = each.value.alias == null ? try(each.value.ttl, 300) : null

  dynamic "alias" {
    for_each = each.value.alias == null ? [] : [each.value.alias]

    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = try(alias.value.evaluate_target_health, true)
    }
  }
}
