# ---------------------------------------------------------------------------------------------------------------------
# Route 53 DNS records with Cloud Front target
# ---------------------------------------------------------------------------------------------------------------------

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
