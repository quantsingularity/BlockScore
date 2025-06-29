
variable "db_username" {
  description = "Database username for the secret."
  type        = string
}

variable "db_password" {
  description = "Database password for the secret."
  type        = string
  sensitive   = true
}


