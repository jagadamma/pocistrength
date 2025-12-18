resource "aws_ecs_cluster" "ecs" {
  name = "${var.name_prefix}-${var.environment}-ecs"
  tags = var.tags
}

resource "aws_ecs_task_definition" "task" {
  for_each = var.task_definition

  family                   = "${each.key}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = each.value.cpu
  memory                   = each.value.memory

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = each.key
      image     = each.value.image
      essential = true
      portMappings = [{
        containerPort = each.value.port
        hostPort      = each.value.port
      }]
    }
  ])
}

resource "aws_ecs_service" "service" {
  for_each = var.task_definition

  name            = "${each.key}-service"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.task[each.key].arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  #################################
  # REQUIRED FOR CODEDEPLOY
  #################################
  deployment_controller {
    type = "CODE_DEPLOY"
  }

  #################################
  # NETWORK CONFIGURATION
  #################################
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = var.ecs_security_group_ids
    assign_public_ip = var.assign_public_ip
  }

  #################################
  # LOAD BALANCER
  #################################
  load_balancer {
    # target_group_arn = aws_lb_target_group.tg[each.key].arn
      target_group_arn = aws_lb_target_group.blue[each.key].arn

    container_name   = each.key
    container_port   = each.value.port
  }

  #################################
  # CODEDEPLOY CONTROLS DEPLOYMENT
  #################################
  lifecycle {
    ignore_changes = [
      #   task_definition,
      desired_count,
      #  load_balancer
    ]
  }

  depends_on = [
    aws_lb_listener.listener,
    aws_lb_listener_rule.rule
  ]

  tags = var.tags
}
