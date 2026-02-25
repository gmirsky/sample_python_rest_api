locals {
  acr_name_sanitized = substr(lower(replace(var.acr_name, "_", "")), 0, 50)
}

resource "azurerm_resource_group" "qa" {
  name     = "sample_qa_rg"
  location = var.location
}

resource "azurerm_container_registry" "qa" {
  name                = local.acr_name_sanitized
  resource_group_name = azurerm_resource_group.qa.name
  location            = azurerm_resource_group.qa.location
  sku                 = "Basic"
  admin_enabled       = false
}
