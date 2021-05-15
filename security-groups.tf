
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