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

  tags = {
    Name        = "${var.project_name}-${var.environment}-audit-logs"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_acl" "audit_logs" {
  bucket = aws_s3_bucket.audit_logs.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_versioning" "audit_logs" {
  bucket = aws_s3_bucket.audit_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "audit_logs" {
  bucket = aws_s3_bucket.audit_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-${var.environment}-trail"
  s3_bucket_name                = aws_s3_bucket.audit_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-trail"
    Environment = var.environment
  }

  depends_on = [aws_s3_bucket_acl.audit_logs]
}
