# sample_python_rest_api

This repository contains:
- A Python REST API with host architecture endpoints and HTTPS redirect.
- Terraform for Azure bootstrap state storage and environment infrastructure (dev, qa, prod).
- Scripts for Azure Managed Identity creation and self-signed TLS certificate generation.
- Tests for Python API endpoints and Terraform validation.
- GitHub Actions workflows (manual `workflow_dispatch`) for Terraform and container image CI.

## Repository Structure

- `app/`: FastAPI application source.
- `tests/python/`: Python API endpoint tests.
- `tests/terraform/`: Terraform format/validate tests.
- `scripts/`: Utility scripts.
- `terraform/bootstrap/`: Creates `terraform_tfdata_rg` and storage for tfstate.
- `terraform/envs/dev/`: Provisions `sample_dev_rg` + `sample_dev_acr` (sanitized for Azure naming).
- `terraform/envs/qa/`: Provisions `sample_qa_rg` + `sample_qa_acr` (sanitized for Azure naming).
- `terraform/envs/prod/`: Provisions `sample_prod_rg` + `sample_prod_acr` (sanitized for Azure naming).
- `.github/workflows/`: Manual pipelines for Terraform and image build/scan/push.

## Prerequisites

- Python 3.11+
- Terraform 1.6+
- Azure CLI (`az`) authenticated to Azure
- OpenSSL
- Docker (for container build)

## Azure Managed Identity Script

Script: `scripts/create_terraform_managed_identity.sh`

This script creates a user-assigned managed identity for Terraform and configures a GitHub OIDC federated credential.

Azure values are embedded as requested:
- Tenant ID: `cdfd8274-8496-4ddd-a787-3294cbb74006`
- Subscription ID: `9a9de21e-de1a-4984-81eb-046948ed936a`

Run:

```bash
chmod +x scripts/create_terraform_managed_identity.sh
./scripts/create_terraform_managed_identity.sh gmirsky/sample_python_rest_api
```

Use output values to set repository Variables:
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_CLIENT_ID`
- `TERRAFORM_MI_PRINCIPAL_ID`
- `TFSTATE_STORAGE_ACCOUNT` (you choose this name before bootstrap apply)

## Self-Signed TLS Script

Script: `scripts/generate_tls_certs.sh`

Run:

```bash
chmod +x scripts/generate_tls_certs.sh
./scripts/generate_tls_certs.sh certs 365
```

Creates:
- `certs/server.crt`
- `certs/server.key`

## Python REST API

Endpoints:
- `GET /health` → `OK`
- `GET /ipv4` → host IPv4 address
- `GET /ipv6` → host IPv6 address (or fallback text)
- `GET /arch` → host architecture
- `GET /uptime` → host uptime in seconds
- `GET /hostname` → host hostname

HTTP to HTTPS redirection is enabled via middleware.

Run locally:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
./scripts/generate_tls_certs.sh
uvicorn app.main:app --host 0.0.0.0 --port 8443 --ssl-keyfile certs/server.key --ssl-certfile certs/server.crt
```

## Tests

Run Python + Terraform tests:

```bash
pytest
```

Terraform tests (`tests/terraform/test_terraform_validate.py`) run:
- `terraform fmt -check -recursive`
- `terraform init -backend=false`
- `terraform validate`

for bootstrap/dev/qa/prod Terraform directories.

## Makefile Shortcuts

Common commands:

```bash
make help
make install
make test
make ci-local
make ci-local-fast
make ci-local-tf
make ci-local-all
make ci-local-all-no-venv
make tls-certs
make run-api
```

When to use:
- `make ci-local-all`: run full local checks when your environment may need setup/refresh first.
- `make ci-local-all-no-venv`: run the same checks when your virtual environment and tools are already ready.

Terraform bootstrap:

```bash
export TERRAFORM_MI_PRINCIPAL_ID="<principal-id>"
export TFSTATE_STORAGE_ACCOUNT="<storage-account-name>"
make tf-bootstrap-init
make tf-bootstrap-validate
make tf-bootstrap-plan
make tf-bootstrap-apply
```

Terraform env backends (dev/qa/prod init):

```bash
export TFSTATE_STORAGE_ACCOUNT="<storage-account-name>"
export AZURE_TENANT_ID="cdfd8274-8496-4ddd-a787-3294cbb74006"
export AZURE_SUBSCRIPTION_ID="9a9de21e-de1a-4984-81eb-046948ed936a"
export AZURE_CLIENT_ID="<managed-identity-client-id>"
make tf-dev-init && make tf-dev-plan
make tf-qa-init && make tf-qa-plan
make tf-prod-init && make tf-prod-plan
```

## Terraform: Bootstrap State Infrastructure

Directory: `terraform/bootstrap`

Creates:
- Resource group: `terraform_tfdata_rg`
- Storage account: `${TFSTATE_STORAGE_ACCOUNT}`
- Blob container: `tfstate`
- RBAC assignment (`Storage Blob Data Contributor`) for `TERRAFORM_MI_PRINCIPAL_ID`

Local plan/apply example:

```bash
cd terraform/bootstrap
terraform init
terraform validate
terraform plan \
  -var="terraform_principal_id=<TERRAFORM_MI_PRINCIPAL_ID>" \
  -var="tfstate_storage_account_name=<TFSTATE_STORAGE_ACCOUNT>"
terraform apply -auto-approve \
  -var="terraform_principal_id=<TERRAFORM_MI_PRINCIPAL_ID>" \
  -var="tfstate_storage_account_name=<TFSTATE_STORAGE_ACCOUNT>"
```

## Terraform: Dev / QA / Prod Infrastructure

Each environment stores tfstate in the bootstrap storage account under separate keys:
- Dev: `dev.tfstate`
- QA: `qa.tfstate`
- Prod: `prod.tfstate`

Environment resources:
- Dev: `sample_dev_rg`, ACR from `sample_dev_acr`
- QA: `sample_qa_rg`, ACR from `sample_qa_acr`
- Prod: `sample_prod_rg`, ACR from `sample_prod_acr`

Note: Azure Container Registry names allow only lowercase alphanumeric characters, so underscores are removed in Terraform before creation.

## GitHub Workflows (manual only)

All workflows are triggered only with `workflow_dispatch`:

### Bootstrap tfstate infrastructure
- `tf-bootstrap-plan.yml`
- `tf-bootstrap-apply.yml`
- `tf-bootstrap-destroy.yml`

### Dev infrastructure
- `tf-dev-plan.yml`
- `tf-dev-apply.yml`
- `tf-dev-destroy.yml`

### QA infrastructure
- `tf-qa-plan.yml`
- `tf-qa-apply.yml`
- `tf-qa-destroy.yml`

### Prod infrastructure
- `tf-prod-plan.yml`
- `tf-prod-apply.yml`
- `tf-prod-destroy.yml`

### API image build/scan/push
- `api-image-dev.yml`
- `api-image-qa.yml`
- `api-image-prod.yml`

Image workflows:
- Build Docker image using Chainguard Python base image.
- Scan with Trivy for `HIGH,CRITICAL` vulnerabilities.
- Push to environment ACR.

## Required GitHub Repository Variables

Set these in repository settings (`Settings` → `Secrets and variables` → `Actions`):
- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `TERRAFORM_MI_PRINCIPAL_ID`
- `TFSTATE_STORAGE_ACCOUNT`

