resource "massdriver_artifact" "vnet" {
  field                = "vnet"
  provider_resource_id = azurerm_virtual_network.main.id
  type                 = "azure-virtual-network"
  name                 = "Virtual Network ${var.md_metadata.name_prefix} (${azurerm_virtual_network.main.id})"
  artifact = jsonencode(
    {
      data = {
        infrastructure = {
          id                = azurerm_virtual_network.main.id
          cidr              = var.cidr
          default_subnet_id = azurerm_subnet.main.id
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
