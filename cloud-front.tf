# ---------------------------------------------------------------------------------------------------------------------
# Cloud Front distribution for static webstie. Bucket access using Origin Access Identity 
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_cloudfront_origin_access_identity" "cloud-front-oai" {
  comment = "Access ${var.domain_name} S3 bucket content only through CloudFront"
}

resource "aws_cloudfront_distribution" "cloud-front-website-distribution" {
  enabled             = var.enabled
  is_ipv6_enabled     = var.is_ipv6_enabled
  comment             = var.comment
  default_root_object = var.default_root_object
  price_class         = var.price_class
  aliases             = [var.domain_name]

  viewer_certificate {
    acm_certificate_arn            = var.ssl_certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = var.minimum_protocol_version
    cloudfront_default_certificate = false
  }

  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_path = var.origin_path
    origin_id   = aws_s3_bucket.website_bucket.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cloud-front-oai.cloudfront_access_identity_path
    }
  }


  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.cached_methods
    target_origin_id = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    compress         = var.compress

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = var.viewer_protocol_policy
    default_ttl            = var.default_ttl
    min_ttl                = var.min_ttl
    max_ttl                = var.max_ttl

  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  wait_for_deployment = var.wait_for_deployment
  web_acl_id          = var.web_acl_id

  tags = merge(

    var.common_tags,
    {
      "Name"      = "Main website"
      "Component" = "Frontend"
    },
  )
}


