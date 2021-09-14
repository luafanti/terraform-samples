# ---------------------------------------------------------------------------------------------------------------------
# AWS COMMON
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ssm_parameter" "ssm_aws_region" {
  name  = "/${var.stack_name}/${var.environment}/aws/region"
  type  = "String"
  value = var.aws_region

  tags = var.common_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# SocketLabs
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ssm_parameter" "ssm_integrations_socketlabs_server_id" {
  name  = "/${var.stack_name}/${var.environment}/integrations/socketLabs/serverId"
  type  = "SecureString"
  value = var.integration_socketlabs_server_id

  tags = var.common_tags
}

resource "aws_ssm_parameter" "ssm_integrations_socketlabs_api_key" {
  name  = "/${var.stack_name}/${var.environment}/integrations/socketLabs/apiKey"
  type  = "SecureString"
  value = var.integration_socketlabs_server_api_key

  tags = var.common_tags
}

resource "aws_ssm_parameter" "ssm_integrations_socketlabs_notifications_api_key" {
  name  = "/${var.stack_name}/${var.environment}/integrations/socketLabs/notificationsApiKey"
  type  = "SecureString"
  value = var.integration_socketlabs_notifications_api_key

  tags = var.common_tags
}

resource "aws_ssm_parameter" "ssm_integrations_socketlabs_non_tracking_server_id" {
  name  = "/${var.stack_name}/${var.environment}/integrations/socketLabs/nonTracking/serverId"
  type  = "SecureString"
  value = var.integration_socketlabs_non_tracking_server_id

  tags = var.common_tags
}

resource "aws_ssm_parameter" "ssm_integrations_socketlabs_non_tracking_sending_api_key" {
  name  = "/${var.stack_name}/${var.environment}/integrations/socketLabs/nonTracking/apiKey"
  type  = "SecureString"
  value = var.integration_socketlabs_non_tracking_api_key

  tags = var.common_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# DataDog
# ---------------------------------------------------------------------------------------------------------------------


resource "aws_ssm_parameter" "ssm_integrations_datadog_api_key" {
  name  = "/${var.stack_name}/${var.environment}/integrations/dataDog/apiKey"
  type  = "SecureString"
  value = var.integration_datadog_api_key

  tags = var.common_tags
}

resource "aws_ssm_parameter" "ssm_integrations_datadog_app_id" {
  name  = "/${var.stack_name}/${var.environment}/integrations/dataDog/appId"
  type  = "SecureString"
  value = var.integration_datadog_app_id

  tags = var.common_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Elastic IO
# ---------------------------------------------------------------------------------------------------------------------


resource "aws_ssm_parameter" "ssm_integrations_elastic_api_key" {
  name  = "/${var.stack_name}/${var.environment}/integrations/elastic/apiKey"
  type  = "SecureString"
  value = var.integration_elastic_api_key

  tags = var.common_tags

}
