<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.44 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.61.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.tfstate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_storage_account.tfstate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.tfstate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Azure region for the Terraform state resources. | `string` | `"eastus"` | no |
| <a name="input_tfstate_storage_account_name"></a> [tfstate\_storage\_account\_name](#input\_tfstate\_storage\_account\_name) | Globally unique Azure Storage Account name for Terraform state. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_tfstate_container_name"></a> [tfstate\_container\_name](#output\_tfstate\_container\_name) | n/a |
| <a name="output_tfstate_resource_group_name"></a> [tfstate\_resource\_group\_name](#output\_tfstate\_resource\_group\_name) | n/a |
| <a name="output_tfstate_storage_account_name"></a> [tfstate\_storage\_account\_name](#output\_tfstate\_storage\_account\_name) | n/a |
<!-- END_TF_DOCS -->