# ---------------------------------------------------------------------------------------------------------------------
# Route 53 DNS records with Cloud Front target
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route53_record" "root_dns-root-ipv4" {
  zone_id = var.route53_zone_id
  name    = var.root_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cloud-front-website-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cloud-front-website-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "root_dns-root-ipv6" {
  zone_id = var.route53_zone_id
  name    = var.root_domain_name
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.cloud-front-website-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cloud-front-website-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}


#Config for app.* prefix
resource "aws_route53_record" "dns-root-ipv4" {
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cloud-front-website-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cloud-front-website-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

#Config for app.* prefix
resource "aws_route53_record" "dns-root-ipv6" {
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.cloud-front-website-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cloud-front-website-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

#Config for www.* prefix
resource "aws_route53_record" "dns-www-ipv4" {
  zone_id = var.route53_zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cloud-front-website-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cloud-front-website-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

#Config for www.* prefix
resource "aws_route53_record" "dns-www-ipv6" {
  zone_id = var.route53_zone_id
  name    = "www.${var.domain_name}"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.cloud-front-website-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cloud-front-website-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

#Cognito auth*.
resource "aws_route53_record" "auth-cognito-A" {
  name    = aws_cognito_user_pool_domain.cognito_own_domain.domain
  type    = "A"
  zone_id = var.route53_zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_cognito_user_pool_domain.cognito_own_domain.cloudfront_distribution_arn
    # This zone_id is fixed
    zone_id = "Z2FDTNDATAQYW2"
  }
}

#ALB api*.
resource "aws_route53_record" "alb-alias" {

  name    = var.backend_domain_name
  type    = "A"
  zone_id = var.route53_zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_alb.alb.dns_name
    zone_id                = aws_alb.alb.zone_id
  }
}

resource "aws_ssm_parameter" "api_domain" {
  name  = "/${var.stack_name}/${var.environment}/route53/apiDomain"
  type  = "String"
  value = var.backend_domain_name

  tags = var.common_tags
}

resource "aws_ssm_parameter" "app_main_domain" {
  name  = "/${var.stack_name}/${var.environment}/route53/appMainDomain"
  type  = "String"
  value = var.domain_name

  tags = var.common_tags
}