output "lb_output" {
  value       = azurerm_lb.example_lb
  description = "this is a child module, so it return the value"
}