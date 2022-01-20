# AKS の ssh key 情報
# public key
output "aks_ssh_public_key" {
  value     = module.aks.aks_ssh_public_key
  sensitive = true
}
# private key
output "aks_ssh_private_key" {
  value     = module.aks.aks_ssh_private_key
  sensitive = true
}

# aks resource group
output "aks_resource_group" {
  value     = module.aks.return_cluster_info.resource_group_name
  sensitive = false
}

# aks resource group
output "aks_name" {
  value     = module.aks.return_cluster_info.name
  sensitive = false
}

# sql pe ip
output "sql_private_endpoint_ip" {
  value     = module.pe.return_pe_info.custom_dns_configs[0].ip_addresses[0]
  sensitive = false
}

# acr io URL
output "acr_name" {
  value     = module.acr.return_acr_info.name
  sensitive = false
}

