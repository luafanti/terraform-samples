# ---------------------------------------------------------------------------------------------------------------------
# Main config
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  type        = string
  description = "The AWS region to create things in"
}

variable "aws_profile" {
  type        = string
  description = "AWS profile with attached credentials"
}

variable "stack_name" {
  type        = string
  description = "Name of the stack/project"
}

variable "environment" {
  type        = string
  description = "Type on environment eg. dev, stage, prod"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags applied to multiple components"
}


# ---------------------------------------------------------------------------------------------------------------------
# Route 53
# ---------------------------------------------------------------------------------------------------------------------

variable "route53_zone_id" {
  description = "Route 53 existing zone ID (created earlier manually)"
}

variable "root_domain_name" {
  type        = string
  description = "The root domain name address managed by Route53"
}

variable "domain_name" {
  type        = string
  description = "The domain name for the main website managed by Route53"
}

variable "ssl_certificate_arn" {
  description = "ARN of SSL certificate generate by AWS ACM"
}

# ---------------------------------------------------------------------------------------------------------------------
# S3
# ---------------------------------------------------------------------------------------------------------------------

variable "frontend_bucket_name" {
  type        = string
  description = "The name of the bucket when reside all static frontend files"
}

variable "force_destroy" {
  type        = string
  description = "All objects should be deleted from the bucket so that the bucket can be destroyed without error"
  default     = "true"
}

# ---------------------------------------------------------------------------------------------------------------------
# Cloud Front
# ---------------------------------------------------------------------------------------------------------------------

variable "basic_auth_user" {
  type        = string
  description = "Username for Basic Authentication"
}

variable "basic_auth_password" {
  type        = string
  description = "Password for Basic Authentication"
}

variable "enabled" {
  description = "Whether the distribution is enabled to accept end user requests for content"
  default     = "true"
}

variable "is_ipv6_enabled" {
  description = "Whether IPv6 is enabled for the distribution"
  default     = "true"
}

variable "minimum_protocol_version" {
  description = "The minimum TLS version that you want CloudFront to use for HTTPS connections"
  default     = "TLSv1.2_2018"
}

variable "origin_path" {
  description = "Causes CloudFront to request content from a directory in your S3 bucket"
  default     = ""
}

variable "compress" {
  description = "Compress content for web requests that include Accept-Encoding: gzip in the request header"
  default     = "true"
}

variable "default_root_object" {
  description = "An object CloudFront returns when the end user requests the root URL"
  default     = "index.html"
}

variable "comment" {
  description = "Distribution comments"
  default     = "Main website frontend distribution."
}

variable "price_class" {
  description = "The price class for this distribution (PriceClass_All, PriceClass_200, PriceClass_100)"
  default     = "PriceClass_100"
}

variable "viewer_protocol_policy" {
  description = "The protocol users can use to access the origin files (allow-all, https-only, redirect-to-https)"
  default     = "redirect-to-https"
}

variable "allowed_methods" {
  description = "Controls which HTTP methods CloudFront processes and forwards to your S3 bucket"
  type        = list(string)
  default     = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
}

variable "cached_methods" {
  description = "Controls whether CloudFront caches responses to requests using the specified HTTP methods"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "default_ttl" {
  description = "Default amount of time (in seconds) an object is in a CloudFront cache"
  default     = "3600"
}

variable "min_ttl" {
  description = "Minimum amount of time you want objects to stay in CloudFront caches"
  default     = "0"
}

variable "max_ttl" {
  description = "Maximum amount of time an object is in a CloudFront cache"
  default     = "86400"
}

variable "geo_restriction_type" {
  description = "The method to restrict distribution of your content by country (none, whitelist, blacklist)"
  default     = "none"
}

variable "geo_restriction_locations" {
  description = "ISO 3166-1-alpha-2 country codes"
  type        = list(string)
  default     = []
}

variable "wait_for_deployment" {
  description = "Wait for the distribution status to change from InProgress to Deployed"
  default     = "false"
}

variable "web_acl_id" {
  description = "AWS WAFv2 Web ACL ARN"
  default     = ""
}


# ---------------------------------------------------------------------------------------------------------------------
# ECR/ECS
# ---------------------------------------------------------------------------------------------------------------------

variable "ecr_backend_reposiotry" {
  type        = string  
  description = "Repository name of backend application in container registry"
}


# ---------------------------------------------------------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------------------------------------------------------

variable "vpc_cidr" {
  type = string
  description = "CIDR for the VPC"
  default     = "10.0.0.0/16"
}

variable "az_count" {
  type = string
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}


# ---------------------------------------------------------------------------------------------------------------------
# Cognito
# ---------------------------------------------------------------------------------------------------------------------

variable "cognito_client_name" {
  type = string
  description = "Name of client integrated with cognito"
}

variable "cognito_callback_urls" {
  type = list(string)
  description = "List of allowed callback URLs"
}

variable "cognito_logout_urls" {
  type = list(string)
  description = "List of allowed logout URLs"
}

variable "cognito_default_redirect_uri" {
  type = string
  description = "Default redirect URI. Must be in the list of callback URLs."
}

variable "cognito_read_attributes" {
  type = list(string)
  description = "List of user pool attributes the application client can read from"
}

variable "cognito_write_attributes" {
  type = list(string)
  description = "List of user pool attributes the application client can write to"
}
