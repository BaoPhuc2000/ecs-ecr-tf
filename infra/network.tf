# Dùng lại Default VPC (giống lúc bạn tạo tay qua Console chọn VPC mặc định)
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project_name}-sg"
  description = "Cho phep truy cap port ${var.container_port} de test truc tiep qua Public IP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Test API directly (lab only, not for production)"
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}
