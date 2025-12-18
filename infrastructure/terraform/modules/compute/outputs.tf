output "autoscaling_group_id" {
  description = "ID of the Auto Scaling Group"
  value       = try(aws_autoscaling_group.main[0].id, null)
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = try(aws_autoscaling_group.main[0].name, null)
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = try(aws_launch_template.main.id, null)
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = try(aws_lb.main[0].dns_name, "")
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = try(aws_lb.main[0].arn, null)
}
