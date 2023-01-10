locals {
  json_map = jsondecode(data.http.token.response_body)
  token    = local.json_map["access_token"]
  cidr     = var.network.auto ? utility_available_cidr.cidr.result : var.network.cidr
}

data "http" "token" {
  url    = "https://login.microsoftonline.com/${var.azure_service_principal.data.tenant_id}/oauth2/token"
  method = "POST"

  request_body = "grant_type=Client_Credentials&client_id=${var.azure_service_principal.data.client_id}&client_secret=${var.azure_service_principal.data.client_secret}&resource=https://management.azure.com/"
}

data "http" "list" {
  url    = "https://management.azure.com/subscriptions/${var.azure_service_principal.data.subscription_id}/providers/Microsoft.Network/virtualNetworks?api-version=2022-07-01"
  method = "GET"

  request_headers = {
    "Authorization" = "Bearer ${local.token}"
  }
}

data "jq_query" "list" {
  data  = data.http.list.response_body
  query = "[.value[].properties.addressSpace.addressPrefixes[]]"
}

resource "utility_available_cidr" "cidr" {
  from_cidrs = ["10.0.0.0/8", "172.16.0.0/20", "192.168.0.0/16"]
  used_cidrs = jsondecode(data.jq_query.list.result)
  mask       = 16
}

output "list" {
  value = utility_available_cidr.cidr.result
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
}
