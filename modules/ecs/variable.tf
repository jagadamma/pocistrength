variable "name_prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "desired_count" {
  type = number
}

variable "alb_idle_timeout" {
  type = number
}

variable "assign_public_ip" {
  type = bool
}

variable "execution_role_arn" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "ecs_security_group_ids" {
  type = list(string)
}

variable "alb_security_group_ids" {
  type = list(string)
}

# Multi-service ECS Task Definition List
variable "task_definition" {
  type = map(object({
    image  = string
    port   = number
    cpu    = number
    memory = number
  }))
}

variable "task_role_arn" {
  type = string
}
