
output "application_log_group_name" {
  description = "The name of the CloudWatch log group for application logs."
  value       = aws_cloudwatch_log_group.application_logs.name
}

output "audit_logs_bucket_name" {
  description = "The name of the S3 bucket for audit logs."
  value       = aws_s3_bucket.audit_logs.id
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}
