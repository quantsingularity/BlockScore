output "app_security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.app_sg.id
}

output "db_security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.db_sg.id
}

output "web_waf_sg_id" {
  description = "The ID of the web WAF security group."
  value       = aws_security_group.web_waf.id
}

output "instance_profile_name" {
  description = "The name of the EC2 instance profile."
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}

output "ec2_instance_profile_arn" {
  description = "The ARN of the EC2 instance profile."
  value       = aws_iam_instance_profile.ec2_instance_profile.arn
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for encryption."
  value       = aws_kms_key.main.arn
}

output "rds_monitoring_role_arn" {
  description = "The ARN of the IAM role for RDS enhanced monitoring."
  value       = aws_iam_role.rds_monitoring_role.arn
}
