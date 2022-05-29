locals {
  enable_postgresql_flexible_subnet = true
}

resource "azurerm_subnet" "postgresql_flexible" {
  count                = local.enable_postgresql_flexible_subnet ? 1 : 0
  name                 = "postgresql-flexible"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = var.md_metadata.name_prefix
  address_prefixes     = [local.postgresql_flexible_subnet_cidr]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_dns_zone" "postgresql_flexible" {
  count               = local.enable_postgresql_flexible_subnet ? 1 : 0
  name                = "${var.md_metadata.name_prefix}.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgresql_flexible" {
  count                 = local.enable_postgresql_flexible_subnet ? 1 : 0
  name                  = var.md_metadata.name_prefix
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.postgresql_flexible.name
  virtual_network_id    = azurerm_virtual_network.main.id
}