locals {
  first_service = sort(keys(var.task_definition))[0]
}

resource "aws_lb" "alb" {
  name               = "${var.name_prefix}-${var.environment}-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = var.alb_security_group_ids
  idle_timeout       = var.alb_idle_timeout
  tags               = var.tags
}

# -------- BLUE TARGET GROUPS --------
resource "aws_lb_target_group" "blue" {
  for_each = var.task_definition

  name        = "${each.key}-blue-tg"
  port        = each.value.port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

# -------- GREEN TARGET GROUPS --------
resource "aws_lb_target_group" "green" {
  for_each = var.task_definition

  name        = "${each.key}-green-tg"
  port        = each.value.port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

# -------- LISTENER --------
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue[local.first_service].arn

  }
  
  depends_on = [
    aws_lb_target_group.blue,
    aws_lb_target_group.green
  ]
}

# -------- LISTENER RULES (one per app) --------
resource "aws_lb_listener_rule" "rule" {
  for_each = var.task_definition

  listener_arn = aws_lb_listener.listener.arn
  priority     = 100 + index(keys(var.task_definition), each.key)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue[each.key].arn
  }

  condition {
    path_pattern {
      values = ["/${each.key}/*"]
     }
   }
 }
