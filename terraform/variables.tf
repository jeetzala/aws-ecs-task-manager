variable "aws_region" {
  description = "AWS region for the ECS Task Manager infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "Existing VPC used by the ECS deployment"
  type        = string
  default     = "vpc-095bc20287a249456"
}

variable "public_subnet_ids" {
  description = "Existing public subnets used by the ALB and Fargate service"
  type        = list(string)

  default = [
    "subnet-0ec3e311c10186508",
    "subnet-0a4a37d1be64f284b"
  ]
}

variable "alb_security_group_id" {
  description = "Existing security group ID for the Application Load Balancer"
  type        = string
  default     = "sg-0a3eaa496211739bf"
}

variable "ecs_security_group_id" {
  description = "Existing security group ID for ECS Fargate tasks"
  type        = string
  default     = "sg-063ce3211798f47a7"
}

variable "secret_name" {
  description = "Secrets Manager secret used by the ECS task"
  type        = string
  default     = "task-manager/app-token"
}
