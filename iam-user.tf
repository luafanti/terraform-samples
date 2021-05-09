# ---------------------------------------------------------------------------------------------------------------------
# IAM user for CI/CD purpose - Fronted pipiline
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_user" "frontend_cicd_pipline" {
  name = "frontend_cicd_pipline"

  tags = merge(
    var.common_tags,
    {
      "Component" = "CICD"
    },
  )
}

resource "aws_iam_policy" "frontend_cicd_policy" {
  name   = "WriteToFrontendBucketAndInvalidateCachePolicy"
  policy = data.aws_iam_policy_document.fronted_cicd_policy.json

  tags = merge(
    var.common_tags,
    {
      "Component" = "CICD"
    },
  )
}

data "aws_iam_policy_document" "fronted_cicd_policy" {
  statement {
    sid    = "AllowPutObjectToFrontendBucket"
    effect = "Allow"

    actions = [
    "s3:PutObject"]

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

resource "aws_iam_user_policy_attachment" "frontend_cicd_policy_attach" {
  user       = aws_iam_user.frontend_cicd_pipline.name
  policy_arn = aws_iam_policy.frontend_cicd_policy.arn
}
