resource "massdriver_artifact" "vnet" {
  field                = "vnet"
  provider_resource_id = azurerm_virtual_network.main.id
  name                 = "Virtual Network ${var.md_metadata.name_prefix} (${azurerm_virtual_network.main.id})"
  artifact = jsonencode(
    {
      data = {
        infrastructure = {
          id                = azurerm_virtual_network.main.id
          cidr              = local.cidr
          default_subnet_id = azurerm_subnet.main.id
          name = azurerm_virtual_network.main.name
        }
      }
      specs = {
        azure = {
          region = azurerm_virtual_network.main.location
          resource_group_name = azurerm_virtual_network.main.resource_group_name
        }
      }
    }
  )
}
