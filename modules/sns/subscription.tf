locals {
  subs_map = {
    for s in flatten([
      for topic_name, cfg in var.sns : [
        for sub in lookup(cfg, "subscriptions", []) : {
          key        = "${topic_name}-${sub.protocol}-${sub.endpoint}"
          topic_name = topic_name
          protocol   = sub.protocol
          endpoint   = sub.endpoint
        }
      ]
    ]) :
    s.key => s
  }
}

resource "aws_sns_topic_subscription" "subs" {
  for_each = local.subs_map

  topic_arn = aws_sns_topic.topic[each.value.topic_name].arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint
}
