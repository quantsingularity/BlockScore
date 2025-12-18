variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "db_username" {
  description = "Database username to store in secrets"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password to store in secrets"
  type        = string
  sensitive   = true
}
