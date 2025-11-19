variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The deployment environment (dev, staging, prod)."
  type        = string
}

variable "origin_domain_name" {
  description = "The domain name of the origin (e.g., S3 bucket or ALB)."
  type        = string
}

variable "origin_type" {
  description = "The type of origin (s3 or custom)."
  type        = string
  default     = "custom"
  validation {
    condition     = contains(["s3", "custom"], var.origin_type)
    error_message = "Origin type must be either 's3' or 'custom'."
  }
}

variable "default_root_object" {
  description = "The default root object for the CloudFront distribution."
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "The price class for the CloudFront distribution."
  type        = string
  default     = "PriceClass_100"
}

variable "custom_ssl_certificate_arn" {
  description = "The ARN of a custom SSL certificate from ACM (optional)."
  type        = string
  default     = null
}

variable "web_acl_arn" {
  description = "The ARN of the WAF Web ACL to associate with the CloudFront distribution."
  type        = string
}
