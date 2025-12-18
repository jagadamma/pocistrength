variable "name_prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "pipeline_name" {
  description = "Name of the CodePipeline"
  type        = string
}

variable "artifact_bucket" {
  description = "S3 bucket for CodePipeline artifacts"
  type        = string
}

variable "role_arn" {
  type = string
}

variable "github_owner" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "github_branch" {
  type = string
}

variable "codestar_connection_arn" {
  type        = string
  description = "CodeStar connection ARN for GitHub"
}


#variable "github_token" {
#  type      = string
#  sensitive = true
#}

variable "taskdef_template_path" {
  type        = string
  description = "Task definition template file path"
}


variable "appspec_template_path" {
  type = string
}


variable "codebuild_project_name" {
  type = string
}

variable "codedeploy_app_name" {
  type = string
}

variable "codedeploy_dg_name" {
  type = string
}
