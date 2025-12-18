module "vpc" {
  source        = "../modules/networking/vpc"
  region        = var.region
  environment   = var.environment
  name_prefix   = var.name_prefix
  vpcs          = var.vpcs
  vpc_flow_logs = var.vpc_flow_logs
  common_tags   = var.common_tags
}

module "subnet" {
  source                      = "../modules/networking/subnets"
  vpc_id                      = module.vpc.vpc_ids[0]
  vpc_cidr                    = module.vpc.vpc_cidr[0]
  name_prefix                 = var.name_prefix
  internet_gateway_id         = module.vpc.internet_gateway_ids[0]
  region                      = var.region
  environment                 = var.environment
  nat_gateways                = var.nat_gateways
  private_subnets             = var.private_subnets
  public_subnets              = var.public_subnets
  private_subnet_route_tables = var.private_subnet_route_tables
  public_subnet_route_tables  = var.public_subnet_route_tables
  ecs_security_group_id = aws_security_group.ecs_sg.id

  common_tags                 = var.common_tags
}

module "ecr" {
  source           = "../modules/ecr"
  ecr_repositories = var.ecr_repositories
  lifecycle_policy = var.lifecycle_policy
  common_tags      = var.common_tags
}

module "ecs" {
  source = "../modules/ecs"

  name_prefix        = var.name_prefix
  environment        = var.environment
  vpc_id             = module.vpc.vpc_ids[0]
  private_subnet_ids = module.subnet.private_subnet_ids
  public_subnet_ids  = module.subnet.public_subnet_ids

  desired_count    = var.ecs.desired_count
  alb_idle_timeout = var.ecs.alb_idle_timeout
  assign_public_ip = var.ecs.assign_public_ip

  ecs_security_group_ids = [aws_security_group.ecs_sg.id]
  alb_security_group_ids = [aws_security_group.alb_sg.id]

  # ✅ PASS FULL MAP (NO each.key HERE)
  task_definition = var.task_definition

  execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn      = module.iam.ecs_task_role_arn

  tags = var.common_tags

  depends_on = [
    aws_security_group.alb_sg,
    aws_security_group.ecs_sg
  ]
}


#############################
# ALB Security Group
#############################
resource "aws_security_group" "alb_sg" {
  name   = "${var.name_prefix}-${var.environment}-alb-sg"
  vpc_id = module.vpc.vpc_ids[0]

  dynamic "ingress" {
    for_each = var.security_groups.alb.ingress
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = lookup(ingress.value, "cidr_blocks", [])
    }
  }

}

#############################
# ECS Security Group
#############################
resource "aws_security_group" "ecs_sg" {
  name   = "${var.name_prefix}-${var.environment}-ecs-sg"
  vpc_id = module.vpc.vpc_ids[0]

  dynamic "ingress" {
    for_each = var.security_groups.ecs.ingress
    content {
      from_port = ingress.value.from_port
      to_port   = ingress.value.to_port
      protocol  = ingress.value.protocol

      cidr_blocks = lookup(ingress.value, "cidr_blocks", [])

      security_groups = (
        contains(lookup(ingress.value, "security_groups", []), "alb")
      ) ? [aws_security_group.alb_sg.id] : []
    }
  }

}

module "iam" {
  source      = "../modules/iam"
  name_prefix = var.name_prefix
  codestar_connection_arn = var.cicd.github.connection_arn
  artifact_bucket = var.cicd.artifact_bucket
}

#resource "aws_s3_bucket" "codepipeline_artifacts" {
#  bucket = "sharadha-dev-us-codepipeline-artifacts"

#  force_destroy = true

#  tags = merge(
#    var.common_tags,
#    {
#      Name = "codepipeline-artifacts"
#    }
#  )
#}

module "s3buckets" {
  source = "../modules/s3buckets"

  s3bucketslist = var.s3bucketslist
  common_tags   = var.common_tags
}

#############################
# LOCALS (PUT HERE)
#############################
#locals {
#  s3_bucket_map = {
#    for b in module.s3buckets.s3_bucket_names :
#    b => b
#  }
#}

 module "acm" {
   source = "../modules/acm"

   domains            = var.domains
   multi_domain_cert  = var.multi_domain_cert
   validation_method  = var.validation_method
   # Pick your R53 Hosted Zone ID for validation
   hosted_zone_id = module.route53.zones["harshitha.com"].id
   common_tags        = var.common_tags
 }


 module "cloudfront" {
   source = "../modules/cloudfront"

   distributions = var.distributions
 }


 module "rds" {
  source             = "../modules/rds"
  vpc_id             = module.vpc.vpc_ids[0]
  vpc_cidr           = module.vpc.vpc_cidr[0]
  rds                = var.rds
  private_subnet_ids = module.subnet.private_subnet_ids
  common_tags        = var.common_tags
 }

 module "route53" {
   source = "../modules/route53"
   vpc_id       = module.vpc.vpc_ids[0]
   hosted_zones = var.hosted_zones
   records      = var.records
   common_tags = var.common_tags
 }

 module "secrets" { 
   source                                  = "../modules/secrets" 
   secrets_list                            = var.secrets_list
   common_tags                             = var.common_tags
 }

 module "sns" {
   source = "../modules/sns"
   sns   = var.sns
   common_tags   = var.common_tags
 }

 module "sqs" {
   source      = "../modules/sqs"
   sqs_queues  = var.sqs_queues
   common_tags = var.common_tags
   }

module "codebuild" {
  for_each     = var.task_definition
  source       = "../modules/codebuild"
  project_name = var.cicd.codebuild.project_name

  name_prefix  = var.name_prefix
  environment  = var.environment
  region       = var.region
  service_name = each.key
  service_role = module.iam.codebuild_role_arn
  ecr_repo_url = module.ecr.repo_urls[var.service_ecr_map[each.key]]


  tags = var.common_tags
}

resource "aws_codedeploy_app" "ecs" {
  name             = "${var.name_prefix}-${var.environment}-ecs-app"
  compute_platform = "ECS"
}


module "codedeploy" {
  for_each = var.task_definition

  source              = "../modules/codedeploy"
  codedeploy_app_name = aws_codedeploy_app.ecs.name
  name_prefix         = var.name_prefix
  environment         = var.environment

  service_role_arn = module.iam.codedeploy_role_arn


  ecs_cluster_name = module.ecs.cluster_name
  ecs_service_name = module.ecs.service_names[each.key]

  alb_listener_arn = module.ecs.alb_listener_arn
  blue_tg_name     = module.ecs.blue_tg_names[each.key]
  green_tg_name    = module.ecs.green_tg_names[each.key]


}

module "codepipeline" {
  for_each = var.task_definition
  source   = "../modules/codepipeline"

  name_prefix = var.name_prefix
  environment = var.environment

  #  pipeline_name   = var.cicd.pipeline_name
  pipeline_name   = "${var.cicd.pipeline_name}-${each.key}"

  artifact_bucket = var.cicd.artifact_bucket

  role_arn = module.iam.codepipeline_role_arn

  github_owner  = var.cicd.github.owner
  github_repo   = var.cicd.github.repo
  github_branch = var.cicd.github.branch
  codestar_connection_arn = var.cicd.github.connection_arn

  #  github_token  = var.cicd.github.token

  codebuild_project_name = module.codebuild[each.key].project_name
  codedeploy_app_name    = module.codedeploy[each.key].app_name
  codedeploy_dg_name     = module.codedeploy[each.key].dg_name
  taskdef_template_path = "taskdef-${each.key}.json"
  appspec_template_path = "appspec-${each.key}.yaml"

  depends_on = [
    module.s3buckets
  ]
}
