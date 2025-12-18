# BlockScore Infrastructure Deployment Guide

## Prerequisites

### Required Tools

Install the following tools before proceeding:

```bash
# Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform --version

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

# Helm (optional)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Ansible
sudo pip3 install ansible ansible-lint

# TFLint
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# tfsec
wget https://github.com/aquasecurity/tfsec/releases/latest/download/tfsec-linux-amd64
chmod +x tfsec-linux-amd64
sudo mv tfsec-linux-amd64 /usr/local/bin/tfsec
```

### AWS Configuration

```bash
# Configure AWS credentials
aws configure

# Or use environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-west-2"
```

## Step 1: Terraform Infrastructure Deployment

### 1.1 Prepare Configuration

```bash
cd infrastructure/terraform

# Copy example variables and customize
cp terraform.tfvars.example terraform.tfvars.local
vim terraform.tfvars.local  # Update with your values

# Set database password via environment variable (recommended)
export TF_VAR_db_password="your-strong-password-here"
```

### 1.2 Initialize Terraform

```bash
# Initialize without remote backend (local development)
terraform init -backend=false

# Or configure remote backend
terraform init \
  -backend-config="bucket=my-terraform-state-bucket" \
  -backend-config="key=blockscore/dev/terraform.tfstate" \
  -backend-config="region=us-west-2" \
  -backend-config="dynamodb_table=terraform-state-lock"
```

### 1.3 Validate Configuration

```bash
# Format code
terraform fmt -recursive

# Validate syntax
terraform validate

# Run TFLint
tflint --init
tflint --recursive

# Run tfsec
tfsec .
```

### 1.4 Plan and Apply

```bash
# Plan for dev environment
terraform plan \
  -var-file="environments/dev/terraform.tfvars" \
  -out=tfplan-dev

# Review the plan
terraform show tfplan-dev

# Apply
terraform apply tfplan-dev

# Or use auto-approve for non-prod
terraform apply \
  -var-file="environments/dev/terraform.tfvars" \
  -auto-approve
```

### 1.5 Verify Deployment

```bash
# Show outputs
terraform output

# List all resources
terraform state list

# Show specific resource
terraform state show module.network.aws_vpc.main
```

## Step 2: Kubernetes Deployment

### 2.1 Configure kubectl

```bash
# For AWS EKS
aws eks update-kubeconfig --region us-west-2 --name blockscore-cluster

# Verify connection
kubectl cluster-info
kubectl get nodes
```

### 2.2 Create Secrets

```bash
cd infrastructure/kubernetes

# Copy example secrets file
cp base/app-secrets.example.yaml base/app-secrets.yaml

# Edit with real values (DO NOT COMMIT)
vim base/app-secrets.yaml

# Apply secrets
kubectl apply -f base/app-secrets.yaml
```

### 2.3 Validate Manifests

```bash
# YAML lint
yamllint base/*.yaml

# Dry-run validation
kubectl apply --dry-run=client -f base/

# If using kustomize
kubectl kustomize base/ | kubectl apply --dry-run=client -f -
```

### 2.4 Deploy Applications

```bash
# Apply all base manifests
kubectl apply -f base/

# Or apply selectively
kubectl apply -f base/backend-deployment.yaml
kubectl apply -f base/backend-service.yaml
kubectl apply -f base/frontend-deployment.yaml
kubectl apply -f base/frontend-service.yaml
kubectl apply -f base/ingress.yaml

# Check deployment status
kubectl get pods -w
kubectl get services
kubectl get ingress
```

### 2.5 Verify Deployment

```bash
# Check pod status
kubectl get pods -l app=blockscore-backend
kubectl describe pod <pod-name>
kubectl logs <pod-name>

# Check services
kubectl get svc
kubectl describe svc blockscore-backend

# Test backend health
kubectl port-forward svc/blockscore-backend 8080:8080
curl http://localhost:8080/health
```

## Step 3: Ansible Configuration

### 3.1 Prepare Inventory

```bash
cd infrastructure/ansible

# Copy example inventory
cp inventory/hosts.example.yml inventory/hosts.yml

# Update with your server IPs
vim inventory/hosts.yml
```

### 3.2 Test Connectivity

```bash
# Ping all hosts
ansible all -m ping

# Check connectivity
ansible all -m setup -a "filter=ansible_distribution*"
```

### 3.3 Run Playbooks

```bash
# Dry run (check mode)
ansible-playbook playbooks/main.yml --check

# Run with verbose output
ansible-playbook playbooks/main.yml -v

# Run specific role
ansible-playbook playbooks/main.yml --tags common

# Limit to specific hosts
ansible-playbook playbooks/main.yml --limit webservers
```

### 3.4 Validate with Ansible Lint

```bash
# Lint all playbooks
ansible-lint playbooks/main.yml

# Lint specific role
ansible-lint roles/common/
```

## Step 4: CI/CD Setup

### 4.1 GitHub Actions Secrets

Configure the following secrets in GitHub repository settings:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_ACCESS_KEY_ID_PROD
AWS_SECRET_ACCESS_KEY_PROD
DB_PASSWORD
DB_PASSWORD_PROD
TF_STATE_BUCKET
TF_STATE_LOCK_TABLE
TF_STATE_BUCKET_PROD
TF_STATE_LOCK_TABLE_PROD
```

### 4.2 Test CI Locally

```bash
# Install act (GitHub Actions local runner)
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Run Terraform CI locally
cd infrastructure
act -W ci-cd/terraform-ci.yml -j terraform-validate

# Run Kubernetes CI locally
act -W ci-cd/kubernetes-ci.yml -j kubernetes-lint
```

## Step 5: Monitoring and Verification

### 5.1 Check Terraform State

```bash
cd infrastructure/terraform

# List all resources
terraform state list

# Show VPC details
terraform state show module.network.aws_vpc.main

# Refresh state
terraform refresh -var-file="environments/dev/terraform.tfvars"
```

### 5.2 Verify AWS Resources

```bash
# Check VPC
aws ec2 describe-vpcs --filters "Name=tag:Environment,Values=dev"

# Check RDS
aws rds describe-db-instances

# Check S3 buckets
aws s3 ls

# Check CloudWatch logs
aws logs describe-log-groups
```

### 5.3 Verify Kubernetes Resources

```bash
# Get all resources
kubectl get all -n default

# Check resource usage
kubectl top nodes
kubectl top pods

# View events
kubectl get events --sort-by='.lastTimestamp'
```

## Troubleshooting

### Terraform Issues

```bash
# State lock issue
terraform force-unlock <lock-id>

# Module not found
terraform get -update

# Provider issue
terraform init -upgrade

# Detailed logs
export TF_LOG=DEBUG
terraform plan
```

### Kubernetes Issues

```bash
# Pod not starting
kubectl describe pod <pod-name>
kubectl logs <pod-name> --previous

# Service not accessible
kubectl get endpoints
kubectl describe svc <service-name>

# Ingress issues
kubectl describe ingress blockscore-ingress
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

### Ansible Issues

```bash
# Connection issues
ansible all -m ping -vvv

# SSH debug
ssh -vvv ec2-user@<host-ip>

# Playbook debug
ansible-playbook playbooks/main.yml -vvv --step
```

## Rollback Procedures

### Terraform Rollback

```bash
# Show state history (if using versioned backend)
terraform state list

# Import existing resource
terraform import <resource_type>.<resource_name> <resource_id>

# Destroy specific resource
terraform destroy -target=module.compute
```

### Kubernetes Rollback

```bash
# Rollback deployment
kubectl rollout undo deployment/blockscore-backend

# Rollback to specific revision
kubectl rollout undo deployment/blockscore-backend --to-revision=2

# Check rollout history
kubectl rollout history deployment/blockscore-backend
```
