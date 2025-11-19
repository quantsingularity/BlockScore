resource "aws_secretsmanager_secret" "example" {
  name        = "example-secret"
  description = "Example secret for BlockScore application"
}

resource "aws_secretsmanager_secret_version" "example" {
  secret_id     = aws_secretsmanager_secret.example.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}

output "secret_arn" {
  value = aws_secretsmanager_secret.example.arn
}
