output "return_log_info" {
  value       = azurerm_log_analytics_workspace.example_log
  description = "this is a child module, so it return the value"
}