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
