locals {
  acr_name_sanitized = substr(lower(replace(var.acr_name, "_", "")), 0, 50)
}

resource "azurerm_resource_group" "prod" {
  name     = "sample_prod_rg"
  location = var.location
}

resource "azurerm_container_registry" "prod" {
  name                = local.acr_name_sanitized
  resource_group_name = azurerm_resource_group.prod.name
  location            = azurerm_resource_group.prod.location
  sku                 = "Basic"
  admin_enabled       = false
}
