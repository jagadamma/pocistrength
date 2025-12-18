#resource "aws_codedeploy_app" "ecs" {
#  name             = "${var.name_prefix}-${var.environment}-ecs-app"
#  compute_platform = "ECS"
#}

resource "aws_codedeploy_deployment_group" "ecs" {
  app_name              = var.codedeploy_app_name
  deployment_group_name = "${var.name_prefix}-${var.environment}-${var.ecs_service_name}-dg"
  service_role_arn      = var.service_role_arn

  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"


  ################################
  # REQUIRED FOR ECS
  ################################
  deployment_style {
    deployment_type   = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }



  ################################
  # REQUIRED FOR ECS BLUE/GREEN
  ################################
  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  ################################
  # ECS SERVICE
  ################################
  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }

  ################################
  # LOAD BALANCER (BLUE/GREEN)
  ################################
  load_balancer_info {
    target_group_pair_info {

      prod_traffic_route {
        listener_arns = [var.alb_listener_arn]
      }

      target_group {
        name = var.blue_tg_name
      }

      target_group {
        name = var.green_tg_name
      }
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}
