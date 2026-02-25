#!/usr/bin/env bash
set -euo pipefail

TENANT_ID="cdfd8274-8496-4ddd-a787-3294cbb74006"
SUBSCRIPTION_ID="9a9de21e-de1a-4984-81eb-046948ed936a"
IDENTITY_RG="terraform_identity_rg"
IDENTITY_LOCATION="eastus"
IDENTITY_NAME="terraform-mi"
GITHUB_ORG_REPO="${1:-}"

if ! command -v az >/dev/null 2>&1; then
  echo "Azure CLI (az) is required but not installed."
  exit 1
fi

if [[ -z "$GITHUB_ORG_REPO" ]]; then
  echo "Usage: $0 <github-org/repo>"
  echo "Example: $0 gmirsky/sample_python_rest_api"
  exit 1
fi

az login --tenant "$TENANT_ID" --allow-no-subscriptions >/dev/null
az account set --subscription "$SUBSCRIPTION_ID"

az group create \
  --name "$IDENTITY_RG" \
  --location "$IDENTITY_LOCATION" \
  --output none

az identity create \
  --name "$IDENTITY_NAME" \
  --resource-group "$IDENTITY_RG" \
  --location "$IDENTITY_LOCATION" \
  --output none

IDENTITY_CLIENT_ID="$(az identity show --name "$IDENTITY_NAME" --resource-group "$IDENTITY_RG" --query clientId -o tsv)"
IDENTITY_PRINCIPAL_ID="$(az identity show --name "$IDENTITY_NAME" --resource-group "$IDENTITY_RG" --query principalId -o tsv)"
IDENTITY_RESOURCE_ID="$(az identity show --name "$IDENTITY_NAME" --resource-group "$IDENTITY_RG" --query id -o tsv)"

az role assignment create \
  --assignee-object-id "$IDENTITY_PRINCIPAL_ID" \
  --assignee-principal-type ServicePrincipal \
  --role Contributor \
  --scope "/subscriptions/$SUBSCRIPTION_ID" \
  --output none || true

az identity federated-credential create \
  --name "github-main" \
  --identity-name "$IDENTITY_NAME" \
  --resource-group "$IDENTITY_RG" \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "repo:${GITHUB_ORG_REPO}:ref:refs/heads/main" \
  --audience "api://AzureADTokenExchange" \
  --output none || true

echo "Managed Identity created/configured successfully."
echo "TENANT_ID=$TENANT_ID"
echo "SUBSCRIPTION_ID=$SUBSCRIPTION_ID"
echo "TERRAFORM_MI_CLIENT_ID=$IDENTITY_CLIENT_ID"
echo "TERRAFORM_MI_PRINCIPAL_ID=$IDENTITY_PRINCIPAL_ID"
echo "TERRAFORM_MI_RESOURCE_ID=$IDENTITY_RESOURCE_ID"
echo "Set repository variables/secrets:"
echo "- AZURE_TENANT_ID=$TENANT_ID"
echo "- AZURE_SUBSCRIPTION_ID=$SUBSCRIPTION_ID"
echo "- AZURE_CLIENT_ID=$IDENTITY_CLIENT_ID"
echo "- TERRAFORM_MI_PRINCIPAL_ID=$IDENTITY_PRINCIPAL_ID"
