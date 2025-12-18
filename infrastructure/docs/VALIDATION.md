# Infrastructure Validation Guide

This document contains all commands to validate the BlockScore infrastructure.

## Quick Validation

Run all validations:

```bash
cd infrastructure
./tests/infrastructure_validation.sh
```

## Terraform Validation

### Format Check

```bash
cd terraform

# Check formatting (exit code 0 = formatted, 3 = needs formatting)
terraform fmt -check -recursive

# Auto-format
terraform fmt -recursive
```

### Syntax Validation

```bash
# Initialize
terraform init -backend=false

# Validate
terraform validate

# Expected output:
# Success! The configuration is valid.
```

### TFLint

```bash
cd terraform

# Initialize TFLint
tflint --init

# Run linter
tflint --recursive

# Expected: No errors (warnings acceptable)
```

### tfsec Security Scan

```bash
cd terraform

# Run security scan
tfsec .

# Or with specific checks
tfsec . --minimum-severity MEDIUM
```

### Checkov Security Scan

```bash
# Using Docker
docker run --rm -v $(pwd):/tf bridgecrew/checkov -d /tf/terraform/

# Or if installed locally
checkov -d terraform/ --framework terraform
```

## Kubernetes Validation

### YAML Lint

```bash
cd kubernetes

# Lint all YAML files
yamllint base/*.yaml

# Expected: No errors (warnings acceptable with line-length)
```

### Dry-Run Validation

```bash
cd kubernetes

# Validate all manifests
kubectl apply --dry-run=client -f base/

# Validate specific file
kubectl apply --dry-run=client -f base/backend-deployment.yaml

# Expected: Resources would be created (dry run)
```

### Kubeval (if available)

```bash
# Install kubeval
wget https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-linux-amd64.tar.gz
tar xf kubeval-linux-amd64.tar.gz
sudo mv kubeval /usr/local/bin/

# Validate manifests
kubeval kubernetes/base/*.yaml

# Expected: All valid
```

### Kustomize Build (if using kustomize)

```bash
cd kubernetes

# Build and validate
kubectl kustomize base/

# Apply dry-run
kubectl kustomize base/ | kubectl apply --dry-run=client -f -
```

## Ansible Validation

### Syntax Check

```bash
cd ansible

# Check playbook syntax
ansible-playbook playbooks/main.yml --syntax-check

# Expected: playbook: playbooks/main.yml
```

### Ansible Lint

```bash
cd ansible

# Lint all playbooks and roles
ansible-lint .

# Lint specific playbook
ansible-lint playbooks/main.yml

# Expected: No fatal errors (warnings acceptable)
```

### YAML Lint for Ansible

```bash
cd ansible

# Lint all YAML files
yamllint inventory/ playbooks/ roles/

# Expected: No errors
```

### Dry-Run (Check Mode)

```bash
cd ansible

# Run in check mode (no changes)
ansible-playbook playbooks/main.yml --check

# With diff to see what would change
ansible-playbook playbooks/main.yml --check --diff
```

## CI/CD Validation

### GitHub Actions Workflow Syntax

```bash
cd ci-cd

# Using actionlint (install from https://github.com/rhysd/actionlint)
actionlint terraform-ci.yml
actionlint kubernetes-ci.yml

# Or using act
act -W terraform-ci.yml --list
```

### YAML Lint for CI

```bash
cd ci-cd

# Lint workflow files
yamllint *.yml

# Expected: No errors
```

## Complete Validation Script

```bash
#!/bin/bash
# Run all validations

set -e

echo "=== Terraform Validation ==="
cd terraform
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
tflint --init
tflint --recursive
cd ..

echo "=== Kubernetes Validation ==="
cd kubernetes
yamllint base/*.yaml
kubectl apply --dry-run=client -f base/
cd ..

echo "=== Ansible Validation ==="
cd ansible
ansible-playbook playbooks/main.yml --syntax-check
ansible-lint .
cd ..

echo "=== CI/CD Validation ==="
cd ci-cd
yamllint *.yml
cd ..

echo "=== All validations passed! ==="
```

## Security Validation

### Check for Hardcoded Secrets

```bash
# Using grep
grep -r -i "password\|secret\|key" terraform/ --exclude-dir=.terraform | grep -v "example\|CHANGE_ME"

# Using trufflehog (if available)
trufflehog --regex --entropy=False .

# Expected: No hardcoded secrets found
```

### Check for Open Security Groups

```bash
# Find 0.0.0.0/0 in Terraform
grep -r "0.0.0.0/0" terraform/

# Review each instance - ensure it's intentional (like ALB ingress)
```

## Validation Outputs

### Expected Terraform Output

```
Success! The configuration is valid.
```

### Expected Kubectl Dry-Run Output

```
deployment.apps/blockscore-backend created (dry run)
service/blockscore-backend created (dry run)
...
```

### Expected Ansible Syntax Check

```
playbook: playbooks/main.yml
```

## Continuous Validation

### Pre-Commit Hooks

```bash
# Install pre-commit
pip install pre-commit

# Create .pre-commit-config.yaml
cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.83.5
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_tflint
  - repo: https://github.com/ansible/ansible-lint
    rev: v6.22.0
    hooks:
      - id: ansible-lint
EOF

# Install hooks
pre-commit install

# Run manually
pre-commit run --all-files
```

## Validation in CI/CD

All validations are automatically run in CI/CD pipelines:

- **Terraform CI**: Runs format, validate, tflint, tfsec, checkov
- **Kubernetes CI**: Runs yamllint, kubectl dry-run, kubeval
- **Ansible CI**: Runs syntax-check, ansible-lint

See `.github/workflows/` or `ci-cd/` for full CI configuration.
