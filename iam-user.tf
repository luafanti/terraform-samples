# ---------------------------------------------------------------------------------------------------------------------
# IAM users for CI/CD purpose - Bitbucket pipiline
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_user" "frontend_cicd_pipline" {
  name = "frontend_cicd_pipline"

  tags = merge(
    var.common_tags,
    {
      "Component" = "CI/CD"
    },
  )
}

resource "aws_iam_user" "backend_cicd_pipline" {
  name = "backend_cicd_pipline"

  tags = merge(
    var.common_tags,
    {
      "Component" = "CI/CD"
    },
  )
}

resource "aws_iam_policy" "frontend_cicd_policy" {
  name   = "WriteToFrontendBucketAndInvalidateCachePolicy"
  policy = data.aws_iam_policy_document.fronted_cicd_policy.json

  tags = merge(
    var.common_tags,
    {
      "Component" = "CI/CD"
    },
  )
}

resource "aws_iam_policy" "backend_cicd_policy" {
  name   = "EnableAuthorizeToEcr"
  policy = data.aws_iam_policy_document.backend_cicd_policy.json

  tags = merge(
    var.common_tags,
    {
      "Component" = "CI/CD"
    },
  )
}

resource "aws_iam_policy" "backend_cicd_ecs_deployment_policy" {
  name   = "AllowCreateECSDeployment"
  policy = data.aws_iam_policy_document.backend_ecs_deployment_cicd_policy.json

  tags = merge(
    var.common_tags,
    {
      "Component" = "CI/CD"
    },
  )
}

data "aws_iam_policy_document" "fronted_cicd_policy" {
  statement {
    sid    = "AllowSyncFrontendBucket"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:ListBucket"
    ]

    resources = ["arn:aws:s3:::${var.frontend_bucket_name}/*"]
  }

  statement {
    sid    = "AllowInvalidateFrontendCache"
    effect = "Allow"

    actions = [
    "cloudfront:CreateInvalidation"]

    resources = [aws_cloudfront_distribution.cloud-front-website-distribution.arn]
  }
}

data "aws_iam_policy_document" "backend_cicd_policy" {
  statement {
    sid    = "AllowEcrAuthorization"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "backend_ecs_deployment_cicd_policy" {

  statement {
    sid    = "AllowUpdateECSService"
    effect = "Allow"
    actions = [
      "ecs:UpdateService",
      "codedeploy:GetApplicationRevision",
      "codedeploy:RegisterApplicationRevision"
    ]

    resources = [
      aws_ecs_service.backend-service.id,
      aws_codedeploy_app.backend-deployment-app.arn
    ]
  }

  statement {
    sid    = "AllowCreateDeployment"
    effect = "Allow"
    actions = [
      "codedeploy:CreateDeployment"
    ]

    resources = [
      aws_codedeploy_deployment_group.backend-deployment-group.arn
    ]
  }

  statement {
    sid    = "AllowReadDeploymentConfig"
    effect = "Allow"
    actions = [
      "codedeploy:GetDeploymentConfig"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowReadTaskDefinition"
    effect = "Allow"
    actions = [
      "ecs:ListTaskDefinitions",
      "ecs:DescribeTaskDefinition"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowWriteToDeploymentBucket"
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]

    resources = ["${aws_s3_bucket.deployment_bucket.arn}/*"]
  }
}

resource "aws_iam_user_policy_attachment" "frontend_cicd_policy_attach" {
  user       = aws_iam_user.frontend_cicd_pipline.name
  policy_arn = aws_iam_policy.frontend_cicd_policy.arn
}

resource "aws_iam_user_policy_attachment" "backend_cicd_policy_attach" {
  user       = aws_iam_user.backend_cicd_pipline.name
  policy_arn = aws_iam_policy.backend_cicd_policy.arn
}

resource "aws_iam_user_policy_attachment" "backend_cicd_ecs_deployment_policy_attach" {
  user       = aws_iam_user.backend_cicd_pipline.name
  policy_arn = aws_iam_policy.backend_cicd_ecs_deployment_policy.arn
}
