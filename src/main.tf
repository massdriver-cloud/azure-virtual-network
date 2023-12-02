locals {
  token_response = var.network.automatic ? jsondecode(data.http.token.0.response_body) : {}
  token          = lookup(local.token_response, "access_token", "")
  cidr           = var.network.automatic ? utility_available_cidr.cidr.0.result : var.network.cidr
}

resource "azurerm_resource_group" "main" {
  name     = var.md_metadata.name_prefix
  location = var.network.region
  tags     = var.md_metadata.default_tags
}

resource "azurerm_virtual_network" "main" {
  name                = var.md_metadata.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = [local.cidr]
  tags                = var.md_metadata.default_tags
}

resource "azurerm_subnet" "main" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(local.cidr, 1, 0)]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault"]
}
