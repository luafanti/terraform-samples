resource "aws_cognito_user_pool" "pool" {
  name = "${var.stack_name}-user-pool"

  mfa_configuration        = "OFF"
  auto_verified_attributes = ["email"]

  schema {
    attribute_data_type = "String"
    mutable             = false
    name                = "nickname"
    required            = true

    string_attribute_constraints {
      min_length = 6
      max_length = 32
    }
  }

  password_policy {
    minimum_length    = "8"
    require_lowercase = false
    require_numbers   = false
    require_symbols   = false
    require_uppercase = false
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  tags = var.common_tags
}

resource "aws_cognito_user_pool_client" "user_pool_client" {

  user_pool_id = aws_cognito_user_pool.pool.id

  name                   = var.cognito_client_name
  refresh_token_validity = 30
  read_attributes        = var.cognito_read_attributes
  write_attributes       = var.cognito_write_attributes


  supported_identity_providers = ["COGNITO"]
  callback_urls                = var.cognito_callback_urls
  logout_urls                  = var.cognito_logout_urls
  default_redirect_uri         = var.cognito_default_redirect_uri

  generate_secret      = true
  explicit_auth_flows  = ["ADMIN_NO_SRP_AUTH"]
  allowed_oauth_flows  = ["code"]
  allowed_oauth_scopes = ["phone", "openid", "profile"]

}

resource "aws_cognito_user_pool_domain" "cognito_own_domain" {
  domain          = "auth.${var.root_domain_name}"
  certificate_arn = var.ssl_certificate_arn
  user_pool_id    = aws_cognito_user_pool.pool.id
}


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


resource "aws_ssm_parameter" "ssm_cognito_user_poll_client_id" {
  name  = "/${var.stack_name}/${var.environment}/cognito/clientId"
  type  = "String"
  value = aws_cognito_user_pool_client.user_pool_client.id

  tags = var.common_tags
}

resource "aws_ssm_parameter" "ssm_cognito_user_poll_client_secret" {
  name  = "/${var.stack_name}/${var.environment}/cognito/clientSecret"
  type  = "String"
  value = aws_cognito_user_pool_client.user_pool_client.client_secret

  tags = var.common_tags
}

resource "aws_ssm_parameter" "ssm_cognito_user_poll_scopes" {
  name  = "/${var.stack_name}/${var.environment}/cognito/scopes"
  type  = "StringList"
  value = join(",", aws_cognito_user_pool_client.user_pool_client.allowed_oauth_scopes)

  tags = var.common_tags
}

resource "aws_ssm_parameter" "ssm_cognito_user_poll_name" {
  name  = "/${var.stack_name}/${var.environment}/cognito/name"
  type  = "String"
  value = aws_cognito_user_pool_client.user_pool_client.name

  tags = var.common_tags
}

resource "aws_ssm_parameter" "ssm_cognito_user_poll_id" {
  name  = "/${var.stack_name}/${var.environment}/cognito/poleId"
  type  = "String"
  value = aws_cognito_user_pool_client.user_pool_client.user_pool_id

  tags = var.common_tags
}

resource "aws_ssm_parameter" "ssm_cognito_url" {
  name  = "/${var.stack_name}/${var.environment}/cognito/domain"
  type  = "String"
  value = aws_cognito_user_pool_domain.cognito_own_domain.domain

  tags = var.common_tags
}