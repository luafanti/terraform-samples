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

  schema {
    attribute_data_type = "String"
    mutable             = true
    name                = "client_id"
    required            = false

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  password_policy {
    minimum_length    = "8"
    require_lowercase = false
    require_numbers   = false
    require_symbols   = false
    require_uppercase = false
    temporary_password_validity_days = 7
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
  read_attributes        = var.cognito_read_attributes
  write_attributes       = var.cognito_write_attributes


  supported_identity_providers = ["COGNITO"]
  callback_urls                = var.cognito_callback_urls
  logout_urls                  = var.cognito_logout_urls
  default_redirect_uri         = var.cognito_default_redirect_uri

  allowed_oauth_flows_user_pool_client = true
  generate_secret      = false
  explicit_auth_flows  = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH",]
  allowed_oauth_flows  = ["implicit"]
  allowed_oauth_scopes = ["email", "openid", "profile"]

  id_token_validity = 1
  access_token_validity = 1
  refresh_token_validity = 30

  prevent_user_existence_errors = "ENABLED"

  token_validity_units {
    access_token = "days"
    id_token = "days"
    refresh_token = "days"
  }

}

resource "aws_cognito_user_pool_ui_customization" "cognito_ui" {
  client_id = aws_cognito_user_pool_client.user_pool_client.id
  css        = file("resources/cognito-ui.css")
  image_file = filebase64("resources/veita-logo.png")
  user_pool_id = aws_cognito_user_pool_domain.cognito_own_domain.user_pool_id
}

resource "aws_cognito_user_pool_domain" "cognito_own_domain" {
  domain          = "auth.${var.root_domain_name}"
  certificate_arn = var.ssl_certificate_arn
  user_pool_id    = aws_cognito_user_pool.pool.id
}

resource "aws_ssm_parameter" "ssm_cognito_user_poll_client_id" {
  name  = "/${var.stack_name}/${var.environment}/cognito/clientId"
  type  = "String"
  value = aws_cognito_user_pool_client.user_pool_client.id

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

resource "aws_ssm_parameter" "ssm_cognito_user_poll_endpoint" {
  name  = "/${var.stack_name}/${var.environment}/cognito/poleEndpoint"
  type  = "String"
  value = aws_cognito_user_pool.pool.endpoint

  tags = var.common_tags
}

resource "aws_ssm_parameter" "ssm_cognito_auth_domain" {
  name  = "/${var.stack_name}/${var.environment}/cognito/domain"
  type  = "String"
  value = aws_cognito_user_pool_domain.cognito_own_domain.domain

  tags = var.common_tags
}


