output "web_acl_arn" {
  description = "The ARN of the WAF Web ACL."
  value       = aws_wafv2_web_acl.main.arn
}

output "web_acl_id" {
  description = "The ID of the WAF Web ACL."
  value       = aws_wafv2_web_acl.main.id
}

output "waf_log_group_arn" {
  description = "The ARN of the WAF CloudWatch log group."
  value       = aws_cloudwatch_log_group.waf_logs.arn
}
