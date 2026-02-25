resource "azurerm_resource_group" "tfstate" {
  name     = "terraform_tfdata_rg"
  location = var.location
}

resource "azurerm_storage_account" "tfstate" {
  name                            = var.tfstate_storage_account_name
  resource_group_name             = azurerm_resource_group.tfstate.name
  location                        = azurerm_resource_group.tfstate.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

# resource "azurerm_role_assignment" "tfstate_blob_access" {
#   scope                = azurerm_storage_account.tfstate.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = var.terraform_principal_id
# }
