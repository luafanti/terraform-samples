# ---------------------------------------------------------------------------------------------------------------------
# ECS CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.stack_name}-Cluster"

  tags = merge(
    var.common_tags,
    {
      Component = "Backend"
    }
  )
}

resource "aws_ecs_task_definition" "task-def" {
  family                   = var.ecs_service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = aws_iam_role.tasks-service-role.arn

   tags = merge(
    var.common_tags,
    {
      Component = "Backend"
    }
  )

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${aws_ecr_repository.backend_repository.repository_url}",
    "memory": ${var.fargate_memory},
    "name": "${var.ecs_service_name}",
    "networkMode": "awsvpc",
    "environment": [
            {"name": "SPRING_PROFILES_ACTIVE", "value": "prod"},
            {"name": "OBSERVABILITY_DATADOG_ENABLED", "value": "true"}
        ],
    "secrets": [
            {"name": "DATA_SOURCE_POSTGRES_JDBC_URL", "valueFrom": "${aws_ssm_parameter.ssm_rds_jdbc_url.arn}"},
            {"name": "DATA_SOURCE_POSTGRES_USERNAME", "valueFrom": "${aws_ssm_parameter.ssm_rds_username.arn}"},
            {"name": "DATA_SOURCE_POSTGRES_PASSWORD", "valueFrom": "${aws_ssm_parameter.ssm_rds_password.arn}"},
            {"name": "SECURITY_COGNITO_CLIENT_NAME", "valueFrom": "${aws_ssm_parameter.ssm_cognito_user_poll_name.arn}"},
            {"name": "SECURITY_COGNITO_CLIENT_ID", "valueFrom": "${aws_ssm_parameter.ssm_cognito_user_poll_client_id.arn}"},
            {"name": "SECURITY_COGNITO_CLIENT_SECRET", "valueFrom": "${aws_ssm_parameter.ssm_cognito_user_poll_client_secret.arn}"},
            {"name": "SECURITY_COGNITO_USER_POOL_ENDPOINT", "valueFrom": "${aws_ssm_parameter.ssm_cognito_user_poll_endpoint.arn}"},
            {"name": "SECURITY_COGNITO_AUTH_DOMAIN", "valueFrom": "${aws_ssm_parameter.ssm_cognito_auth_domain.arn}"},
            {"name": "APP_API_DOMAIN", "valueFrom": "${aws_ssm_parameter.api_domain.arn}"},
            {"name": "APP_MAIN_DOMAIN", "valueFrom": "${aws_ssm_parameter.app_main_domain.arn}"},
            {"name": "INTEGRATIONS_SOCKETLABS_SERVER_ID", "valueFrom": "${aws_ssm_parameter.ssm_integrations_socketlabs_server_id.arn}"},
            {"name": "INTEGRATIONS_SOCKETLABS_API_KEY", "valueFrom": "${aws_ssm_parameter.ssm_integrations_socketlabs_api_key.arn}"},
            {"name": "OBSERVABILITY_DATADOG_API_KEY", "valueFrom": "${aws_ssm_parameter.ssm_integrations_datadog_api_key.arn}"},
            {"name": "OBSERVABILITY_DATADOG_APPLICATION_KEY", "valueFrom": "${aws_ssm_parameter.ssm_integrations_datadog_app_id.arn}"}
        ],
    "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${aws_cloudwatch_log_group.ecs_workloads.name}",
                "awslogs-region": "${var.aws_region}",
                "awslogs-stream-prefix": "${var.ecs_service_name}"
            }
        },
    "portMappings": [
      {
        "containerPort": ${var.container_port},
        "hostPort": ${var.container_port}
      }
    ]
  }
]
DEFINITION
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS SERVICE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_service" "backend-service" {
  name                              = "${var.ecs_service_name}-service"
  cluster                           = aws_ecs_cluster.ecs-cluster.id
  task_definition                   = aws_ecs_task_definition.task-def.arn
  desired_count                     = var.task_count
  health_check_grace_period_seconds = 360
  force_new_deployment              = true 
  launch_type                       = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.task-sg.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.blue-target-group.id
    container_name   = var.ecs_service_name
    container_port   = var.container_port
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  depends_on = [
    aws_alb_listener.alb-listener,
  ]

  tags = merge(
    var.common_tags,
    {
      Component = "Backend"
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "ecs_workloads" {
  name = "ecs_workloads"
}
