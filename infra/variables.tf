variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "ecs-lab-demo"
}

variable "container_port" {
  type    = number
  default = 8080
}
