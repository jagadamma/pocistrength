output "zones" {
  value = {
    for k, v in aws_route53_zone.zones :
    k => {
      id   = v.zone_id
      name = v.name
    }
  }
}
