# ---------------------------------------------------------------------------------------------------------------------
# ECR 
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecr_repository" "backend_reposiotry" {
  name                 = var.ecr_backend_reposiotry
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    var.common_tags,
    {
      "Component" = "CI/CD"
    },
  )
}

resource "aws_ecr_lifecycle_policy" "ecr_base_lifecycle_policy" {
  repository = aws_ecr_repository.backend_reposiotry.name

# TODO attach policy as varaible
  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 60 tagged images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["test", "dev", "prod"],
                "countType": "imageCountMoreThan",
                "countNumber": 60
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Keep last 30 untagged images",
            "selection": {
                "tagStatus": "untagged",
                "countType": "imageCountMoreThan",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_repository_policy" "ecr_cicd_policy" {
  repository = aws_ecr_repository.backend_reposiotry.name
  policy = data.aws_iam_policy_document.ecr_repository_policy.json
}

data "aws_iam_policy_document" "ecr_repository_policy" {
  statement {
    sid    = "AllowPushPull"
    effect = "Allow"

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.backend_cicd_pipline.arn]
    }
  }
}

resource "aws_ssm_parameter" "ssm_ecr_url" {
  name  = "/${var.stack_name}/${var.environment}/ecr/url"
  type  = "String"
  value = aws_ecr_repository.backend_reposiotry.repository_url

  tags = var.common_tags
}