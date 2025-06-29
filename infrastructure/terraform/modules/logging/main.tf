resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "/${var.project_name}/${var.environment}/application-logs"
  retention_in_days = 90 # Retain logs for 90 days for compliance

  tags = {
    Name        = "${var.project_name}-${var.environment}-application-logs"
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "audit_logs" {
  bucket = "${var.project_name}-${var.environment}-audit-logs-${var.aws_region}"
  acl    = "log-delivery-write" # Required for S3 access logs

  versioning {
    enabled = true
  }

  server_side_encryption configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-audit-logs"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_policy" "audit_logs_policy" {
  bucket = aws_s3_bucket.audit_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "S3BucketPolicyForCloudTrail"
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.audit_logs.arn
      },
      {
        Sid       = "S3BucketPolicyForCloudTrail2"
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.audit_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
    ]
  })
}

resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-${var.environment}-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.audit_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-cloudtrail"
    Environment = var.environment
  }
}

data "aws_caller_identity" "current" {}


