variable "name_prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "service_role_arn" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_service_name" {
  type = string
}

variable "alb_listener_arn" {
  type = string
}

variable "blue_tg_name" {
  type = string
}

variable "green_tg_name" {
  type = string
}
variable "codedeploy_app_name" {
  type = string
}

