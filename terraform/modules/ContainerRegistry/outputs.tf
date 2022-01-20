output "return_acr_info" {
  value       = azurerm_container_registry.sample_acr
  description = "this is a child module, so it return the value"
}