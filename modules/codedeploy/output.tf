#output "app_name" {
#  description = "CodeDeploy application name"
#  value       = aws_codedeploy_app.ecs.name
#}

output "dg_name" {
  description = "CodeDeploy deployment group name"
  value       = aws_codedeploy_deployment_group.ecs.deployment_group_name
}
output "app_name" {
  description = "CodeDeploy application name"
  value       = var.codedeploy_app_name
}

