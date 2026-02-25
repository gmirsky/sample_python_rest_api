locals {
  acr_name_sanitized = substr(lower(replace(var.acr_name, "_", "")), 0, 50)
}

resource "azurerm_resource_group" "dev" {
  name     = "sample_dev_rg"
  location = var.location
}

resource "azurerm_container_registry" "dev" {
  name                = local.acr_name_sanitized
  resource_group_name = azurerm_resource_group.dev.name
  location            = azurerm_resource_group.dev.location
  sku                 = "Basic"
  admin_enabled       = false
}
