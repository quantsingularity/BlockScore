output "db_credentials_secret_arn" {
  description = "The ARN of the database credentials secret."
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "api_keys_secret_arn" {
  description = "The ARN of the API keys secret."
  value       = aws_secretsmanager_secret.api_keys.arn
}

output "secret_arn" {
  description = "The ARN of the primary (database credentials) secret."
  value       = aws_secretsmanager_secret.db_credentials.arn
}
