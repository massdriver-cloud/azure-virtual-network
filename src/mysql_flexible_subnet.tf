locals {
  enable_mysql_flexible_subnet = true
}

resource "azurerm_subnet" "mysql_flexible" {
  count                = local.enable_mysql_flexible_subnet ? 1 : 0
  name                 = "mysql-flexible"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = var.md_metadata.name_prefix
  address_prefixes     = [local.mysql_flexible_subnet_cidr]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_dns_zone" "mysql_flexible" {
  count               = local.enable_mysql_flexible_subnet ? 1 : 0
  name                = "${var.md_metadata.name_prefix}.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql_flexible" {
  count                 = local.enable_mysql_flexible_subnet ? 1 : 0
  name                  = var.md_metadata.name_prefix
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql_flexible.0.name
  virtual_network_id    = azurerm_virtual_network.main.id
}