variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The deployment environment (dev, staging, prod)."
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "The name of the EC2 Key Pair to use for SSH access."
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate with the instances."
  type        = list(string)
}

variable "iam_instance_profile_name" {
  description = "The name of the IAM instance profile to associate with the instances."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "subnet_ids" {
  description = "A list of private subnet IDs where the Auto Scaling Group will launch instances."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "A list of public subnet IDs for the Application Load Balancer."
  type        = list(string)
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate for the ALB HTTPS listener."
  type        = string
  default     = null
}

variable "min_size" {
  description = "The minimum size of the Auto Scaling Group."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximum size of the Auto Scaling Group."
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "The desired capacity of the Auto Scaling Group."
  type        = number
  default     = 2
}

variable "root_volume_size" {
  description = "The size of the root EBS volume in GB."
  type        = number
  default     = 20
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key for EBS encryption."
  type        = string
  default     = null
}

variable "access_logs_bucket" {
  description = "S3 bucket for ALB access logs. Set to null to disable."
  type        = string
  default     = null
}
