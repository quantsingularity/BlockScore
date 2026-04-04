.PHONY: help docker-build docker-up docker-down docker-dev docker-logs tf-init tf-plan tf-apply tf-destroy ansible-check ansible-deploy k8s-apply k8s-delete lint test clean

SHELL := /bin/bash
ENV   ?= dev
PROJECT := blockscore

help:
	@echo "BlockScore Infrastructure Makefile"
	@echo ""
	@echo "Docker targets:"
	@echo "  docker-build   Build all Docker images"
	@echo "  docker-up      Start all services (production)"
	@echo "  docker-down    Stop all services"
	@echo "  docker-dev     Start services in development mode"
	@echo "  docker-logs    Tail logs for all services"
	@echo ""
	@echo "Terraform targets:"
	@echo "  tf-init        Initialize Terraform (ENV=dev|staging|prod)"
	@echo "  tf-plan        Run Terraform plan"
	@echo "  tf-apply       Apply Terraform changes"
	@echo "  tf-destroy     Destroy Terraform resources"
	@echo ""
	@echo "Ansible targets:"
	@echo "  ansible-check  Dry-run Ansible playbook"
	@echo "  ansible-deploy Run Ansible playbook"
	@echo ""
	@echo "Kubernetes targets:"
	@echo "  k8s-apply      Apply Kubernetes manifests"
	@echo "  k8s-delete     Delete Kubernetes resources"
	@echo ""
	@echo "Testing:"
	@echo "  lint           Run all linters"
	@echo "  test           Run all validation tests"
	@echo "  clean          Remove generated files"

# ── Docker ─────────────────────────────────────────────────────────────────────

docker-build:
	docker compose build --no-cache

docker-up:
	@if [ ! -f docker/.env ]; then \
		echo "ERROR: docker/.env not found. Copy docker/.env.example to docker/.env and fill in values."; \
		exit 1; \
	fi
	docker compose up -d
	@echo "Services started. Backend: http://localhost:8080  Frontend: http://localhost:80"

docker-down:
	docker compose down

docker-dev:
	@if [ ! -f docker/.env ]; then \
		cp docker/.env.example docker/.env; \
		echo "Created docker/.env from example. Edit it if needed."; \
	fi
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up

docker-logs:
	docker compose logs -f

# ── Terraform ──────────────────────────────────────────────────────────────────

tf-init:
	@echo "Initializing Terraform for environment: $(ENV)"
	cd terraform && terraform init \
		-backend-config="key=blockscore/$(ENV)/terraform.tfstate" \
		-reconfigure

tf-plan:
	@echo "Planning Terraform for environment: $(ENV)"
	cd terraform && terraform plan \
		-var-file="environments/$(ENV)/terraform.tfvars" \
		-out="$(ENV).tfplan"

tf-apply:
	@echo "Applying Terraform for environment: $(ENV)"
	@if [ ! -f terraform/$(ENV).tfplan ]; then \
		echo "ERROR: Run 'make tf-plan ENV=$(ENV)' first."; exit 1; \
	fi
	cd terraform && terraform apply "$(ENV).tfplan"

tf-destroy:
	@echo "WARNING: Destroying ALL Terraform resources for environment: $(ENV)"
	@read -p "Type '$(ENV)' to confirm destruction: " confirm && [ "$$confirm" = "$(ENV)" ] || (echo "Aborted." && exit 1)
	cd terraform && terraform destroy \
		-var-file="environments/$(ENV)/terraform.tfvars"

# ── Ansible ────────────────────────────────────────────────────────────────────

ansible-check:
	cd ansible && ansible-playbook playbooks/main.yml \
		-i inventory/hosts.yml \
		--check --diff

ansible-deploy:
	cd ansible && ansible-playbook playbooks/main.yml \
		-i inventory/hosts.yml \
		--diff

# ── Kubernetes ─────────────────────────────────────────────────────────────────

k8s-apply:
	kubectl apply -f kubernetes/base/ --dry-run=client
	kubectl apply -f kubernetes/base/

k8s-delete:
	@read -p "Delete ALL kubernetes resources? [y/N] " confirm && [ "$$confirm" = "y" ] || (echo "Aborted." && exit 1)
	kubectl delete -f kubernetes/base/

# ── Lint & Test ────────────────────────────────────────────────────────────────

lint:
	@echo "Linting Terraform..."
	cd terraform && terraform fmt -check -recursive || (echo "Run: cd terraform && terraform fmt -recursive" && exit 1)
	@echo "Linting YAML..."
	yamllint -c .yamllint ansible/ kubernetes/ || true
	@echo "Linting Ansible..."
	cd ansible && ansible-lint || true
	@echo "Linting Docker..."
	@which hadolint > /dev/null 2>&1 && hadolint docker/Dockerfile.backend docker/Dockerfile.frontend || echo "hadolint not found, skipping"

test:
	@echo "Running infrastructure validation tests..."
	bash tests/infrastructure_validation.sh
	@echo "Running security scan..."
	bash tests/security_scan.sh
	@echo "Running compliance checks..."
	bash tests/compliance_check.sh

clean:
	rm -f terraform/*.tfplan
	rm -f ansible/ansible.log
	rm -rf reports/
