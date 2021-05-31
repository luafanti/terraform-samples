# ---------------------------------------------------------------------------------------------------------------------
# Cloud Deploy 
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "codedeploy-service-role" {
  name               = "CodeDeployServiceRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.codedeploy-service-assume-policy.json
}

data "aws_iam_policy_document" "codedeploy-service-assume-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codedeploy-pass-role-ecs" {
  statement {
    effect   = "Allow"
    actions  = ["iam:PassRole"]
    resources = [aws_iam_role.tasks-service-role.arn]
  }
}

resource "aws_iam_policy" "codedeploy-pass-role-ecs-policy" {
  name   = "AllowPassCodeDeployRole"
  policy = data.aws_iam_policy_document.codedeploy-pass-role-ecs.json

  tags = merge(
    var.common_tags,
    {
      "Component" = "CI/CD"
    },
  )
}

resource "aws_iam_role_policy_attachment" "codedeploy-attach" {
  role       = aws_iam_role.codedeploy-service-role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

resource "aws_iam_role_policy_attachment" "codedeploy-passrole-policy-attach" {
  role       = aws_iam_role.codedeploy-service-role.name
  policy_arn = aws_iam_policy.codedeploy-pass-role-ecs-policy.arn
}


resource "aws_codedeploy_app" "backend-deployment-app" {
  compute_platform = "ECS"
  name             = "${var.ecs_service_name}-deployment-app"

  tags = merge(
    var.common_tags,
    {
      "Component" = "CI/CD"
    },
  )
}


resource "aws_codedeploy_deployment_group" "backend-deployment-group" {
  app_name               = aws_codedeploy_app.backend-deployment-app.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "${var.ecs_service_name}-blue-green-deployment"
  service_role_arn       = aws_iam_role.codedeploy-service-role.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.ecs-cluster.name
    service_name = aws_ecs_service.backend-service.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_alb_listener.alb-listener.arn]
      }

      target_group {
        name = aws_alb_target_group.blue-target-group.name
      }

      target_group {
        name = aws_alb_target_group.green-target-group.name
      }
    }
  }
}