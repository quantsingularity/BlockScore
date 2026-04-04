aws_region  = "us-west-2"
environment = "dev"
app_name    = "blockscore"

vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-west-2a", "us-west-2b", "us-west-2c"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

instance_type        = "t3.micro"
key_name             = "dev-key"
asg_min_size         = 1
asg_max_size         = 3
asg_desired_capacity = 1

db_instance_class    = "db.t3.micro"
db_name              = "blockscoredb"
db_username          = "blockscore_admin"
db_allocated_storage = 20
# db_password        - set via: export TF_VAR_db_password="your-password"

default_tags = {
  Terraform   = "true"
  Environment = "dev"
  Project     = "blockscore"
}
