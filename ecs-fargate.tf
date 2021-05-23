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
    "secrets": [
            {"name": "JDBC_URL", "valueFrom": "${aws_ssm_parameter.ssm_rds_jdbc_url.arn}"},
            {"name": "DB_USERNAME", "valueFrom": "${aws_ssm_parameter.ssm_rds_username.arn}"},
            {"name": "DB_PASSWORD", "valueFrom": "${aws_ssm_parameter.ssm_rds_password.arn}"}
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
  name                              = "${var.ecs_service_name}-Service"
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
    target_group_arn = aws_alb_target_group.trgp.id
    container_name   = var.ecs_service_name
    container_port   = var.container_port
  }

  depends_on = [
    aws_alb_listener.alb-listener,
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "ecs_workloads" {
  name = "ecs_workloads"
}
