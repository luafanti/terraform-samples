# ---------------------------------------------------------------------------------------------------------------------
# RDS DB SUBNET GROUP
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_db_subnet_group" "db-subnet-grp" {
  name        = "${var.stack_name}-db-sgrp"
  description = "Database Subnet Group"
  subnet_ids  = aws_subnet.private.*.id
}

# ---------------------------------------------------------------------------------------------------------------------
# RDS (MYSQL)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_db_instance" "postgres_rds" {
  identifier        = var.rds_db_instance_id
  allocated_storage = var.rds_db_allocated_storage
  storage_type      = var.rds_db_storage_type
  engine            = "postgres"
  engine_version    = "13.2"
  port              = "5432"
  instance_class    = var.rds_db_instance_type
  name              = var.rds_db_name
  username          = var.rds_db_user
  password          = var.rds_db_password

  storage_encrypted      = true
  deletion_protection    = false
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.db-subnet-grp.id
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.stack_name}-db"
    },
  )
}

resource "aws_ssm_parameter" "ssm_rds_host" {
  name  = "/${var.stack_name}/${var.environment}/rds/host"
  type  = "String"
  value = aws_db_instance.postgres_rds.address

  tags = var.common_tags
}

resource "aws_ssm_parameter" "ssm_rds_port" {
  name  = "/${var.stack_name}/${var.environment}/rds/port"
  type  = "String"
  value = aws_db_instance.postgres_rds.port

  tags = var.common_tags
}

resource "aws_ssm_parameter" "ssm_rds_jdbc_rul" {
  name  = "/${var.stack_name}/${var.environment}/rds/jdbcUrl"
  type  = "String"
  value = "jdbc:postgresql://${aws_db_instance.postgres_rds.address}/${var.rds_db_name}"

  tags = var.common_tags
}

resource "aws_ssm_parameter" "ssm_rds_database" {
  name  = "/${var.stack_name}/${var.environment}/rds/databaseName"
  type  = "String"
  value = var.rds_db_name

  tags = var.common_tags
}

resource "aws_ssm_parameter" "ssm_rds_username" {
  name  = "/${var.stack_name}/${var.environment}/rds/databaseUser"
  type  = "String"
  value = var.rds_db_user

  tags = var.common_tags
}

resource "aws_ssm_parameter" "ssm_rds_password" {
  name  = "/${var.stack_name}/${var.environment}/rds/databasePassword"
  type  = "SecureString"
  value = var.rds_db_password

  tags = var.common_tags
}

