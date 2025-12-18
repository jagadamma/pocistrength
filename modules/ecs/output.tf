output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.ecs.name
}

output "service_names" {
  description = "ECS service names per app"
  value = {
    for k, svc in aws_ecs_service.service :
    k => svc.name
  }
}

output "blue_tg_names" {
  description = "Blue target group names per service"
  value = {
    for k, tg in aws_lb_target_group.blue :
    k => tg.name
  }
}

output "green_tg_names" {
  description = "Green target group names per service"
  value = {
    for k, tg in aws_lb_target_group.green :
    k => tg.name
  }
}

output "alb_listener_arn" {
  description = "ALB listener ARN"
  value       = aws_lb_listener.listener.arn
}
