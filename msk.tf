# # ---------------------------------------------------------------------------------------------------------------------
# # Managed Streaming for Apache Kafka
# # ---------------------------------------------------------------------------------------------------------------------

# resource "aws_msk_cluster" "main-cluster" {
#   cluster_name           = "${var.stack_name}-cluster"
#   kafka_version          = "2.6.1"
#   number_of_broker_nodes = 2

#   broker_node_group_info {
#     instance_type   = "kafka.t3.small"
#     ebs_volume_size = 2
#     client_subnets = aws_subnet.private.*.id
#     security_groups = [aws_security_group.msk-sg.id]
#   }

#   open_monitoring {
#     prometheus {
#       jmx_exporter {
#         enabled_in_broker = true
#       }
#       node_exporter {
#         enabled_in_broker = true
#       }
#     }
#   }

#   logging_info {
#     broker_logs {
#       cloudwatch_logs {
#         enabled   = true
#         log_group = aws_cloudwatch_log_group.msk.name
#       }
#       firehose {
#         enabled         = true
#         delivery_stream = aws_kinesis_firehose_delivery_stream.main_stream.name
#       }
#       s3 {
#         enabled = true
#         bucket  = aws_s3_bucket.msk-logs.id
#         prefix  = "logs/msk-"
#       }
#     }
#   }

#   tags = merge(
#     var.common_tags,
#     {
#       "Component" = "Backend"
#     },
#   )
# }

# resource "aws_cloudwatch_log_group" "msk" {
#   name = "msk_broker_logs"
# }

# resource "aws_s3_bucket" "msk-logs" {
#   bucket = "veita-msk-broker-logs"
#   acl    = "private"

#   tags = merge(
#     var.common_tags,
#     {
#       "Component" = "Backend"
#     },
#   )
# }

# data "aws_iam_policy_document" "firehose_policy" {
  
#   statement {
#     effect = "Allow"
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["firehose.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role" "firehose_role" {
#   name = "firehose_test_role"
#   assume_role_policy = data.aws_iam_policy_document.firehose_policy.json
# }

# resource "aws_kinesis_firehose_delivery_stream" "main_stream" {
#   name        = "terraform-kinesis-firehose-msk-broker-logs-stream"
#   destination = "s3"

#   s3_configuration {
#     role_arn   = aws_iam_role.firehose_role.arn
#     bucket_arn = aws_s3_bucket.msk-logs.arn
#   }

#   lifecycle {
#     ignore_changes = [
#       tags["LogDeliveryEnabled"],
#     ]
#   }

#   tags = merge(
#     var.common_tags,
#     {
#       "Component" = "Backend"
#     },
#   )
# }

# resource "aws_ssm_parameter" "ssm_msk_broker_url" {
#   name  = "/${var.stack_name}/${var.environment}/msk/zookeeperUrl"
#   type  = "String"
#   value = aws_msk_cluster.main-cluster.zookeeper_connect_string

#   tags = var.common_tags
# }

# resource "aws_ssm_parameter" "ssm_msk_zookeeper_url" {
#   name  = "/${var.stack_name}/${var.environment}/msk/brokerUrl"
#   type  = "String"
#   value = aws_msk_cluster.main-cluster.bootstrap_brokers_tls

#   tags = var.common_tags
# }
