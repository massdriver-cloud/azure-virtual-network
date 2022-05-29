resource "massdriver_artifact" "vnet" {
  field                = "vnet"
  provider_resource_id = azurerm_virtual_network.main.id
  type                 = "azure-virtual-network"
  name                 = "Virtual Network ${var.md_metadata.name_prefix} (${azurerm_virtual_network.main.id})"
  artifact = jsonencode(
    {
      data = {
        infrastructure = {
          vnet_id           = azurerm_virtual_network.main.id
          cidr              = var.cidr
          default_subnet_id = azurerm_subnet.main.id
          delegated_subnets = {
            "Microsoft.DBforPostgreSQL/flexibleServers" = {
              subnet_id           = azurerm_subnet.postgresql_flexible.0.id
              private_dns_zone_id = azurerm_private_dns_zone.postgresql_flexible.0.id
            }
            "Microsoft.DBforMySQL/flexibleServers" = {
              subnet_id           = azurerm_subnet.mysql_flexible.0.id
              private_dns_zone_id = azurerm_private_dns_zone.mysql_flexible.0.id
            }
          }
        }
        observability = {
          alarm_monitor_action_group_ari = azurerm_monitor_action_group.main.id
        }
      }
      specs = {
        azure = {
          region = azurerm_virtual_network.main.location
        }
      }
    }
  )
}
