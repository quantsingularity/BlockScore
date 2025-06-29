variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The deployment environment (dev, staging, prod)."
  type        = string
}

variable "log_destination_arn" {
  description = "The ARN of the log destination for WAF logs (e.g., CloudWatch Log Group or S3 bucket)."
  type        = string
}

