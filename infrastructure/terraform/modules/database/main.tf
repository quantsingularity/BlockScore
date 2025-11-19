resource "aws_db_instance" "main" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0.28"
  instance_class       = "db.t3.micro"
  name                 = "${var.project_name}-${var.environment}-db"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  vpc_security_group_ids = [var.db_security_group_id]
  db_subnet_group_name = var.db_subnet_group_name
  publicly_accessible  = false

  # Encryption at rest
  storage_encrypted = true
  kms_key_id        = var.kms_key_arn

  # Enable SSL/TLS for in-transit encryption (requires client-side configuration)
  # This setting is typically configured within the database parameter group or client connection string.
  # For MySQL 8.0, `require_secure_transport` parameter can be set to ON.

  tags = {
    Name        = "${var.project_name}-${var.environment}-db"
    Environment = var.environment
  }
}
