resource "azurerm_resource_group" "main" {
  name     = var.md_metadata.name_prefix
  location = var.azure_region

  tags = var.md_metadata.default_tags
}

resource "azurerm_virtual_network" "main" {
  name                = var.md_metadata.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = [var.cidr]

  tags = var.md_metadata.default_tags
}

resource "azurerm_subnet" "main" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.cidr, 1, 0)]
}
