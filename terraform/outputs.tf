output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.task_manager.dns_name
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.task_manager.repository_url
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.task_manager.arn
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.task_manager.name
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group used by the ECS container"
  value       = aws_cloudwatch_log_group.task_manager.name
}

output "ecs_security_group_id" {
  description = "Security group ID for the ECS tasks"
  value       = aws_security_group.ecs.id
}

output "alb_security_group_id" {
  description = "Security group ID for the ALB"
  value       = aws_security_group.alb.id
}

output "secret_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.task_manager.arn
}
