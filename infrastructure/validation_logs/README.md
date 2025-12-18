# Validation Logs

This directory contains outputs from various validation tools.

## Files

- `terraform_init_full.log` - Terraform initialization output
- `terraform_validate_full.log` - Terraform validation output
- `terraform_fmt.log` - Terraform format check
- `yamllint_kubernetes.log` - YAML lint results for Kubernetes manifests
- `SUMMARY.txt` - Overall summary of fixes and validations

## Running Validations Locally

### Prerequisites

Install required tools:

```bash
# Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# yamllint
pip3 install yamllint

# ansible-lint
pip3 install ansible-lint

# TFLint
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# tfsec
wget https://github.com/aquasecurity/tfsec/releases/latest/download/tfsec-linux-amd64
chmod +x tfsec-linux-amd64
sudo mv tfsec-linux-amd64 /usr/local/bin/tfsec
```

### Terraform Validation

```bash
cd terraform/
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
tflint --init && tflint --recursive
tfsec .
```

### Kubernetes Validation

```bash
yamllint kubernetes/base/*.yaml
kubectl apply --dry-run=client -f kubernetes/base/
```

### Ansible Validation

```bash
cd ansible/
ansible-playbook playbooks/main.yml --syntax-check
ansible-lint .
```

## Expected Results

All validations should pass with:

- Terraform: "Success! The configuration is valid."
- YAML lint: No errors (warnings for line-length are acceptable)
- Ansible: "playbook: playbooks/main.yml"
- kubectl dry-run: Resources created (dry run)

## Notes

- Some tools may not be installed in CI environment
- Manual validation recommended before deployment
- See DEPLOYMENT.md for full deployment procedures
