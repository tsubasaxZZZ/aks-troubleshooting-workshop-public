output "return_output" {
  value       = var.node_pools_info
  description = "this is a child module, so it return the value"
}

output "return_cluster_info" {
  value       = azurerm_kubernetes_cluster.sample_aks
  description = "this is a child module, so it return the value"
}

output "aks_ssh_public_key" { value = tls_private_key.example_ssh_private_key.public_key_openssh }
output "aks_ssh_private_key" { value = tls_private_key.example_ssh_private_key.private_key_pem }