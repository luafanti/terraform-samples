
# ---------------------------------------------------------------------------------------------------------------------
# ALB
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_alb" "alb" {
  name            = "${var.stack_name}-alb"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.alb-sg.id]

  tags = var.common_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# ALB TARGET GROUP
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_alb_target_group" "trgp" {
  name        = "${var.stack_name}-tgrp"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

resource "aws_alb_target_group" "blue-target-group" {
  name        = "${var.stack_name}-blue-tgrp"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

resource "aws_alb_target_group" "green-target-group" {
  name        = "${var.stack_name}-green-tgrp"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

# ---------------------------------------------------------------------------------------------------------------------
# ALB LISTENER
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_alb_listener" "alb-listener" {
  load_balancer_arn = aws_alb.alb.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.alb_ssl_certificate_arn


  default_action {
    target_group_arn = aws_alb_target_group.blue-target-group.id
    type             = "forward"
  }
}

resource "aws_lb_listener" "alb-http-listener" {
  load_balancer_arn = aws_alb.alb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "alb-test-listener" {
  load_balancer_arn = aws_alb.alb.id
  port              = "8443"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.blue-target-group.id
    type             = "forward"
  }
}

resource "aws_ssm_parameter" "ssm_alb_url" {
  name  = "/${var.stack_name}/${var.environment}/alb/url"
  type  = "String"
  value = aws_alb.alb.dns_name

  tags = var.common_tags
}