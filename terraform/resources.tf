locals {
  vpc_id            = var.vpc_id
  public_subnet_ids = var.public_subnet_ids
  alb_sg_id         = var.alb_security_group_id
  ecs_sg_id         = var.ecs_security_group_id
}

data "aws_ecs_task_definition" "current" {
  task_definition = "task-manager"
}

data "aws_iam_role" "ecs_execution" {
  name = "ecsTaskExecutionRole"
}

resource "aws_security_group" "alb" {
  name        = "task-manager-alb-sg"
  description = "Security group for Task Manager Application Load Balancer"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs" {
  name        = "task-manager-ecs-sg"
  description = "Security group for Task Manager ECS Fargate tasks"
  vpc_id      = local.vpc_id

  ingress {
    description     = null
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [local.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "task_manager" {
  name               = "task-manager-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [local.alb_sg_id]
  subnets            = local.public_subnet_ids
  ip_address_type    = "ipv4"
}

resource "aws_lb_target_group" "task_manager" {
  name        = "task-manager-tg"
  port        = 5000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = local.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    port                = "traffic-port"
  }
}

resource "aws_lb_listener" "task_manager" {
  load_balancer_arn = aws_lb.task_manager.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.task_manager.arn

    forward {
      target_group {
        arn    = aws_lb_target_group.task_manager.arn
        weight = 1
      }
    }
  }
}

resource "aws_ecs_cluster" "task_manager" {
  name = "task-manager-cluster-v2"
}

resource "aws_ecs_service" "task_manager" {
  name            = "task-manager-service"
  cluster         = aws_ecs_cluster.task_manager.id
  task_definition = data.aws_ecs_task_definition.current.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  platform_version                  = "LATEST"
  scheduling_strategy               = "REPLICA"
  health_check_grace_period_seconds = 60

  network_configuration {
    subnets          = local.public_subnet_ids
    security_groups  = [local.ecs_sg_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.task_manager.arn
    container_name   = "task-manager"
    container_port   = 5000
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }

  availability_zone_rebalancing = "ENABLED"

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }
}

resource "aws_ecr_repository" "task_manager" {
  name                 = "task-manager"
  image_tag_mutability = "MUTABLE"
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_lifecycle_policy" "task_manager" {
  repository = aws_ecr_repository.task_manager.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the latest 3 tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 3
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "task_manager" {
  name              = "/aws/ecs/task-manager"
  retention_in_days = 7
}

resource "aws_secretsmanager_secret" "task_manager" {
  name = var.secret_name

  lifecycle {
    ignore_changes = [
      force_overwrite_replica_secret,
      recovery_window_in_days
    ]
  }
}

resource "aws_iam_role_policy" "ecs_secret_access" {
  name = "TaskManagerSecretsAccess"
  role = data.aws_iam_role.ecs_execution.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.task_manager.arn
      }
    ]
  })
}

