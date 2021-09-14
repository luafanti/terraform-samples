
# ---------------------------------------------------------------------------------------------------------------------
# ECS TASK ROLE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "tasks-service-role" {
  name               = "ECSTasksServiceRole" 
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.tasks-service-assume-policy.json
}

resource "aws_iam_role" "application_role" {
  name               = "FargateApplicationRole" 
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.tasks-service-assume-policy.json
}

data "aws_iam_policy_document" "tasks-service-assume-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "ssm_access_policy" {
  name        = "ReadFromParameterStore"
  description = "Allow read parameters from SSM Parameter store"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameters"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ssm:eu-central-1:066959768973:parameter/veita/*"
      },
    ]
  })
}

resource "aws_iam_policy" "cognito_user_pool_managment" {
  name        = "ManageCognitoUserPoolAccounts"
  description = "Allow manage cognito user pool accounts"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cognito-idp:AdminDeleteUser",
          "cognito-idp:AdminEnableUser",
          "cognito-idp:AdminCreateUser",
          "cognito-idp:AdminDisableUser",
          "cognito-idp:AdminRemoveUserFromGroup",
          "cognito-idp:AdminAddUserToGroup"
        ]
        Effect   = "Allow"
        Resource = "${aws_cognito_user_pool.pool.arn}"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "tasks-service-role-attachment" {
  role       = aws_iam_role.tasks-service-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "tasks-ssm-policy-attachment" {
  role       = aws_iam_role.tasks-service-role.name
  policy_arn = aws_iam_policy.ssm_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "application_role_cognito_management_policy_attachment" {
  role       = aws_iam_role.application_role.name
  policy_arn = aws_iam_policy.cognito_user_pool_managment.arn
}
