data "http" "token" {
  count  = var.network.automatic ? 1 : 0
  url    = "https://login.microsoftonline.com/${var.azure_service_principal.data.tenant_id}/oauth2/token"
  method = "POST"

  request_body = "grant_type=Client_Credentials&client_id=${var.azure_service_principal.data.client_id}&client_secret=${var.azure_service_principal.data.client_secret}&resource=https://management.azure.com/"
}

data "http" "vpcs" {
  count  = var.network.automatic ? 1 : 0
  url    = "https://management.azure.com/subscriptions/${var.azure_service_principal.data.subscription_id}/providers/Microsoft.Network/virtualNetworks?api-version=2022-07-01"
  method = "GET"

  request_headers = {
    "Authorization" = "Bearer ${local.token}"
  }
}

data "jq_query" "vpc_cidrs" {
  count  = var.network.automatic ? 1 : 0
  data  = data.http.vpcs.0.response_body
  query = "[.value[].properties.addressSpace.addressPrefixes[]]"
}

resource "utility_available_cidr" "cidr" {
  count  = var.network.automatic ? 1 : 0
  from_cidrs = ["10.0.0.0/8", "172.16.0.0/20", "192.168.0.0/16"]
  used_cidrs = jsondecode(data.jq_query.vpc_cidrs.0.result)
  mask       = var.network.mask
}