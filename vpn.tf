resource "aws_ec2_client_vpn_endpoint" "main" {
  description            = "VPN to ${var.stack_name} VPC"
  server_certificate_arn = "arn:aws:acm:eu-central-1:066959768973:certificate/76014748-367c-49c1-bf14-70ac9b31e308"
  client_cidr_block      = "12.0.0.0/16"
  split_tunnel = true

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = "arn:aws:acm:eu-central-1:066959768973:certificate/9eae037b-8e03-402f-a282-e67a8fcf0000"
  }

  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.vpn-connections.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.vpn-connections.name
  }

  tags = var.common_tags
}

resource "aws_ec2_client_vpn_network_association" "main" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  subnet_id              = aws_subnet.public.*.id[0]
}

resource "aws_ec2_client_vpn_authorization_rule" "main" {
  description = "Authorization to whole VPC"
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  target_network_cidr    = aws_vpc.main.cidr_block
  authorize_all_groups   = true
}

resource "aws_cloudwatch_log_group" "vpn-connections" {
  name = "vpn_connection_logs"
}

resource "aws_cloudwatch_log_stream" "vpn-connections" {
  name           = "stream"
  log_group_name = aws_cloudwatch_log_group.vpn-connections.name
}