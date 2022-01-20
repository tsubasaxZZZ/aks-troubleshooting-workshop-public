# Private Link Service 作成
resource "azurerm_private_endpoint" "example_pe" {
  name                = var.pe_name
  location            = var.pe_location
  resource_group_name = var.pe_resource_group_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "${var.pe_name}-privateserviceconnection"
    private_connection_resource_id = var.paas_resource_id
    subresource_names              = var.subresource_names  # https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
    is_manual_connection           = false
  }
}

