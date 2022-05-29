locals {
  // The services range is the last 1/4 of the subnet
  vnet_services_range = cidrsubnet(var.cidr, 2, 3)

  // Take slices out for each services subnet
  postgresql_flexible_subnet_cidr = cidrsubnet(local.vnet_services_range, 6, 0)
  mysql_flexible_subnet_cidr      = cidrsubnet(local.vnet_services_range, 6, 1)
}

# apimanagement        Can be a smaller subnet - these will pair w/ the container instances
# containerinstance    Probably want a bigger subnet here
