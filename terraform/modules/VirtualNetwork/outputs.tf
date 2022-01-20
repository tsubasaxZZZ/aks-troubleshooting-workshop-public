output "network_output" {
  value       = azurerm_subnet.example_subnet
  description = "this is a child module, so it return the value"
}

output "network_info" {
  value       = azurerm_virtual_network.example_vnet
  description = "this is a child module, so it return the value"
}
