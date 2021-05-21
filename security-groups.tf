
# ---------------------------------------------------------------------------------------------------------------------
# Security group for Postgres RDS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "db-sg" {
  name        = "${var.stack_name}-db-sg"
  description = "Access to the RDS instances from the VPC"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
     Name = "${var.stack_name}-db-sg"
    },
  )
}



# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUP FOR ALB
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "alb-sg" {
  name        = "${var.stack_name}-alb-sg"
  description = "Allow inbound access ALB from internet"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.stack_name}-alb-sg"
    }
  )
}

resource "aws_security_group_rule" "alb_https_ingress" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb-sg.id
}

resource "aws_security_group_rule" "alb_http_ingress" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb-sg.id
}

# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUP FOR ECS TASKS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "task-sg" {
  name        = "${var.stack_name}-task-sg"
  description = "Allow inbound access to ECS tasks from the ALB only"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol        = "tcp"
    from_port       = var.container_port
    to_port         = var.container_port
    security_groups = [aws_security_group.alb-sg.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.stack_name}-task-sg"
    }
  )
}
