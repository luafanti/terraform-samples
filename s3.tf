# ---------------------------------------------------------------------------------------------------------------------
# S3 Bucket for static website files (frontend) 
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "website_bucket" {
  bucket        = var.frontend_bucket_name
  acl           = "private"
  force_destroy = var.force_destroy

  tags = merge(
    var.common_tags,
    {
      "Component" = "Frontend"
    },
  )
}

resource "aws_s3_bucket_public_access_block" "website_bucket_private_access" {
  bucket                  = aws_s3_bucket.website_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = data.aws_iam_policy_document.origi_access_identity_policy.json
}

# IAM Policy for Cloud Front Origin Access Identity to S3 website bucket 
data "aws_iam_policy_document" "origi_access_identity_policy" {
  statement {
    sid    = "CloudFrontOAItoS3"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cloud-front-oai.iam_arn]
    }

    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.frontend_bucket_name}${var.origin_path}/*"]
  }
}
