variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

variable "multi_domain_cert" {
  description = "ACM multi-domain (SAN) certificate configuration"
  type = object({
    domain_name               = string
    subject_alternative_names = list(string)
  })
}




#variable "services" {
#  description = "Application services with ECS + CI/CD"
#  type = map(object({
#    github = object({
#      owner  = string
#      repo   = string
#      branch = string
#    })
#
#    container = object({
#      image  = string
#      port   = number
#      cpu    = number
#      memory = number
#    })
#  }))
#}


# -----------------------------
# VPC Inputs
# -----------------------------
variable "vpcs" {
  type = list(any)
}

variable "vpc_flow_logs" {
  type = any
}

# -----------------------------
# Subnet Inputs
# -----------------------------
variable "public_subnets" {
  type = list(any)
}

variable "private_subnets" {
  type = list(any)
}

#variable "db_subnets" {
#  type = list(any)
#}

variable "role_name" {
  description = "The name of the IAM role"
  type        = string
}

variable "terraform_oidc_policy" {
  description = "The ARN of the IAM policy to attach to the role"
  type        = string
}

variable "github_repository" {
  description = "List of GitHub repositories to allow for access"
  type        = list(string)
}

variable "aws_account_id" {
  description = "The AWS account ID where resources will be created"
  type        = string
}

variable "public_subnet_route_tables" {
  type = list(any)
}

variable "private_subnet_route_tables" {
  type = list(any)
}

variable "db_subnet_route_tables" {
  type = list(any)
}

variable "nat_gateways" {
  type = list(any)
}

# -----------------------------
# ECS Inputs
# -----------------------------
variable "ecs" {
  type = object({
    container_image  = string
    container_port   = number
    task_cpu         = number
    task_memory      = number
    container_name   = string # NEW
    assign_public_ip = bool   # NEW
    desired_count    = number
    alb_idle_timeout = number
  })
}
variable "task_definition" {
  type = map(object({
    image  = string
    port   = number
    cpu    = number
    memory = number
  }))
}


variable "security_groups" {
  type = map(object({
    ingress = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string))
      security_groups = optional(list(string))
    }))
    egress = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  }))
}


# -----------------------------
# ECR Inputs
# -----------------------------
variable "ecr_repositories" {
  description = "List of ECR repositories"
  type = list(object({
    name              = string
    enable_lifecycle  = bool
    enable_scanning   = bool
    tag_mutability    = string
    enable_encryption = bool
  }))
}

variable "service_ecr_map" {
  description = "Map ECS services to ECR repositories"
  type        = map(string)
}

variable "hosted_zones" {
  description = "Route53 hosted zones"
  type = map(object({
    comment       = string
    force_destroy = bool
    private_zone  = bool
  }))
}

variable "records" {
  description = "Route53 DNS records"
  type = map(object({
    zone_name = string
    name      = string
    type      = string
    ttl       = number
    records   = list(string)

    # optional alias support (commented in tfvars)
    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = bool
    }))
  }))
}

variable "domains" {
  description = "List of application domains"
  type        = list(string)
}

variable "sns" {
  description = "SNS topics and subscriptions"
  type = map(object({
    display_name = string
    subscriptions = list(object({
      protocol = string
      endpoint = string
    }))
  }))
}

variable "secrets_list" {
  description = "Secrets Manager secrets"
  type = list(object({
    name        = string
    description = string
  }))
}

variable "sqs_queues" {
  description = "SQS queues configuration"
  type = map(object({
    name                       = string
    max_message_size           = number
    message_retention_seconds  = number
    visibility_timeout_seconds = number
    delay_seconds              = number
    receive_wait_time_seconds  = number
    sqs_managed_sse_enabled    = bool
  }))
}


variable "distributions" {
  description = "CloudFront distributions"
  type = map(object({
    domain_name    = string
    hosted_zone_id = string
    origin_path    = string
    tags           = map(string)
  }))
}

variable "kms_key_alias" {
  description = "KMS key alias for ECR encryption"
  type        = string
}

variable "validation_method" {
  description = "ACM certificate validation method"
  type        = string
}


variable "lifecycle_policy" {
  description = "ECR lifecycle policy"
  type = object({
    rulePriority = number
    description  = string
    tagStatus    = string
    countType    = string
    countNumber  = number
    actionType   = string
  })
}

#variable "kms_key_alias" {
#  type = string
#}

# -----------------------------
# RDS Inputs
# -----------------------------
variable "rds" {
  type = map(object({
    name                                  = string
    db_identifier                         = string
    db_name                               = string
    engine                                = string
    engine_version                        = string
    allocated_storage                     = number
    instance_class                        = string
    db_username                           = string
    parameter_group_name                  = string
    parameter_group_family                = string
    backup_retention_period               = number
    port                                  = number
    db_sg_name                            = string
    subnet_group_name                     = string
    kms_key_name                          = string
    storage_type                          = string
    auto_minor_version_upgrade            = bool
    multi_az                              = bool
    publicly_accessible                   = bool
    skip_final_snapshot                   = bool
    performance_insights_enabled          = bool
    performance_insights_retention_period = number
    copy_tags_to_snapshot                 = bool
    storage_encrypted                     = bool
    deletion_protection                   = bool
  }))
}

# -----------------------------
# S3 Inputs
# -----------------------------
variable "s3bucketslist" {
  type = list(object({
    bucket_name   = string
    force_destroy = bool
    versioning    = bool
    public_access = bool
  }))
}

variable "artifact_bucket" {
  description = "S3 bucket used by CodePipeline and CodeBuild for artifacts"
  type        = string
}

variable "cicd" {
  description = "CI/CD configuration"
  type = object({
    pipeline_name   = string
    artifact_bucket = string

    github = object({
      owner          = string
      repo           = string
      branch         = string
      connection_arn = string
      #      token  = string
    })

    codebuild = optional(object({
      project_name = string
      image        = string
      compute_type = string
    }))

    codedeploy = optional(object({
      application_name = string
      deployment_groups = map(object({
        name = string
      }))
    }))
  })
}
