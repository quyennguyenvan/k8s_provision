
resource "aws_security_group" "ec2_sg" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = var.vpc_id


  dynamic "ingress" {
    for_each = var.sg_sets
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.source
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.sg_name}-admin-sg"
  }, var.default_tags)
}
