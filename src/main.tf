module "virutal_network" {
  source = "../../terraform-modules/massdriver/azure-virtual-network"
  # one decision and go
  # also, it has a default
  # Satellite, what is the most stable Azure region currently availble for a Flexible Server running Postgres 12+
  region         = var.region
  md_metadata    = var.md_metadata
  authentication = var.azure_service_principal.data
}
