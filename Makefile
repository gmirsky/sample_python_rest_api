PYTHON ?= python3
VENV_DIR ?= .venv
PIP := $(VENV_DIR)/bin/pip
PYTEST := $(VENV_DIR)/bin/pytest
UVICORN := $(VENV_DIR)/bin/uvicorn

TFSTATE_RG ?= terraform_tfdata_rg
TFSTATE_SA ?= $(TFSTATE_STORAGE_ACCOUNT)
AZURE_TENANT_ID ?=
AZURE_SUBSCRIPTION_ID ?=
AZURE_CLIENT_ID ?=

.PHONY: help venv install test ci-local ci-local-fast ci-local-tf ci-local-all ci-local-all-no-venv run-api tls-certs \
	tf-bootstrap-init tf-bootstrap-validate tf-bootstrap-plan tf-bootstrap-apply tf-bootstrap-destroy \
	tf-dev-init tf-dev-validate tf-dev-plan tf-dev-apply tf-dev-destroy \
	tf-qa-init tf-qa-validate tf-qa-plan tf-qa-apply tf-qa-destroy \
	tf-prod-init tf-prod-validate tf-prod-plan tf-prod-apply tf-prod-destroy

help:
	@echo "Targets:"
	@echo "  venv, install, test, ci-local, ci-local-fast, ci-local-tf, ci-local-all, ci-local-all-no-venv, tls-certs, run-api"
	@echo "  tf-bootstrap-init|validate|plan|apply|destroy"
	@echo "  tf-dev-init|validate|plan|apply|destroy"
	@echo "  tf-qa-init|validate|plan|apply|destroy"
	@echo "  tf-prod-init|validate|plan|apply|destroy"

venv:
	$(PYTHON) -m venv $(VENV_DIR)

install: venv
	$(PIP) install -r requirements.txt

test:
	$(PYTEST) -q

ci-local-fast: test

ci-local-tf:
	cd terraform/bootstrap && terraform init -backend=false -input=false && terraform validate
	cd terraform/envs/dev && terraform init -backend=false -input=false && terraform validate
	cd terraform/envs/qa && terraform init -backend=false -input=false && terraform validate
	cd terraform/envs/prod && terraform init -backend=false -input=false && terraform validate

ci-local-all: ci-local-fast ci-local-tf

ci-local-all-no-venv: ci-local-fast ci-local-tf

ci-local: test
	cd terraform/bootstrap && terraform init -backend=false -input=false && terraform validate
	cd terraform/envs/dev && terraform init -backend=false -input=false && terraform validate
	cd terraform/envs/qa && terraform init -backend=false -input=false && terraform validate
	cd terraform/envs/prod && terraform init -backend=false -input=false && terraform validate

tls-certs:
	./scripts/generate_tls_certs.sh

run-api:
	$(UVICORN) app.main:app --host 0.0.0.0 --port 8443 --ssl-keyfile certs/server.key --ssl-certfile certs/server.crt

# Bootstrap
TF_BOOTSTRAP_DIR := terraform/bootstrap

TF_BOOTSTRAP_VAR_ARGS = -var="terraform_principal_id=$${TERRAFORM_MI_PRINCIPAL_ID}" -var="tfstate_storage_account_name=$(TFSTATE_SA)"

tf-bootstrap-init:
	cd $(TF_BOOTSTRAP_DIR) && terraform init -input=false

tf-bootstrap-validate:
	cd $(TF_BOOTSTRAP_DIR) && terraform validate

tf-bootstrap-plan:
	cd $(TF_BOOTSTRAP_DIR) && terraform plan -input=false $(TF_BOOTSTRAP_VAR_ARGS)

tf-bootstrap-apply:
	cd $(TF_BOOTSTRAP_DIR) && terraform apply -auto-approve -input=false $(TF_BOOTSTRAP_VAR_ARGS)

tf-bootstrap-destroy:
	cd $(TF_BOOTSTRAP_DIR) && terraform destroy -auto-approve -input=false $(TF_BOOTSTRAP_VAR_ARGS)

# Environment backend args (OIDC)
define TF_BACKEND_ARGS
-backend-config="resource_group_name=$(TFSTATE_RG)" \
-backend-config="storage_account_name=$(TFSTATE_SA)" \
-backend-config="container_name=tfstate" \
-backend-config="key=$(1).tfstate" \
-backend-config="use_oidc=true" \
-backend-config="tenant_id=$(AZURE_TENANT_ID)" \
-backend-config="subscription_id=$(AZURE_SUBSCRIPTION_ID)" \
-backend-config="client_id=$(AZURE_CLIENT_ID)"
endef

# Dev
TF_DEV_DIR := terraform/envs/dev

tf-dev-init:
	cd $(TF_DEV_DIR) && terraform init -input=false $(call TF_BACKEND_ARGS,dev)

tf-dev-validate:
	cd $(TF_DEV_DIR) && terraform validate

tf-dev-plan:
	cd $(TF_DEV_DIR) && terraform plan -out=tfplan -input=false

tf-dev-apply:
	cd $(TF_DEV_DIR) && terraform apply -auto-approve -input=false

tf-dev-destroy:
	cd $(TF_DEV_DIR) && terraform destroy -auto-approve -input=false

# QA
TF_QA_DIR := terraform/envs/qa

tf-qa-init:
	cd $(TF_QA_DIR) && terraform init -input=false $(call TF_BACKEND_ARGS,qa)

tf-qa-validate:
	cd $(TF_QA_DIR) && terraform validate

tf-qa-plan:
	cd $(TF_QA_DIR) && terraform plan -out=tfplan -input=false

tf-qa-apply:
	cd $(TF_QA_DIR) && terraform apply -auto-approve -input=false

tf-qa-destroy:
	cd $(TF_QA_DIR) && terraform destroy -auto-approve -input=false

# Prod
TF_PROD_DIR := terraform/envs/prod

tf-prod-init:
	cd $(TF_PROD_DIR) && terraform init -input=false $(call TF_BACKEND_ARGS,prod)

tf-prod-validate:
	cd $(TF_PROD_DIR) && terraform validate

tf-prod-plan:
	cd $(TF_PROD_DIR) && terraform plan -out=tfplan -input=false

tf-prod-apply:
	cd $(TF_PROD_DIR) && terraform apply -auto-approve -input=false

tf-prod-destroy:
	cd $(TF_PROD_DIR) && terraform destroy -auto-approve -input=false
