output "app_security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.db.id
}

output "web_waf_sg_id" {
  description = "The ID of the web WAF security group."
  value       = aws_security_group.web_waf.id
}

output "app_sg_id" {
  description = "The ID of the application security group."
  value       = aws_security_group.app_sg.id
}

output "db_sg_id" {
  description = "The ID of the database security group."
  value       = aws_security_group.db_sg.id
}

output "ec2_instance_profile_arn" {
  description = "The ARN of the EC2 instance profile."
  value       = aws_iam_instance_profile.ec2_instance_profile.arn
}
