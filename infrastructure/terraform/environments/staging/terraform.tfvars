aws_region  = "us-west-2"
environment = "staging"
app_name    = "blockscore"

vpc_cidr             = "10.1.0.0/16"
availability_zones   = ["us-west-2a", "us-west-2b", "us-west-2c"]
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
private_subnet_cidrs = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]

instance_type        = "t3.small"
key_name             = "staging-key"
asg_min_size         = 1
asg_max_size         = 3
asg_desired_capacity = 2

db_instance_class    = "db.t3.small"
db_name              = "blockscoredb"
db_username          = "blockscore_admin"
db_allocated_storage = 20
# db_password        - set via: export TF_VAR_db_password="your-password"

default_tags = {
  Terraform   = "true"
  Environment = "staging"
  Project     = "blockscore"
}
