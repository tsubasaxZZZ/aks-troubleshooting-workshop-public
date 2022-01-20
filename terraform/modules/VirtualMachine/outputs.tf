# "tls_private_key" は出力名、{...} は出力内容
# 秘密キーと公開キー　を出力するのに使用する
output "tls_private_key" { value = tls_private_key.example_ssh01.private_key_pem }
output "tls_public_key" { value = tls_private_key.example_ssh01.public_key_openssh }

output "linux_vm_nic_id_output" {
  value       = azurerm_network_interface.example_nic01.id
  description = "this is a child module, so it return the value"
}

output "linux_vm_nic_config_name_output" {
  value       = azurerm_network_interface.example_nic01.ip_configuration.0.name
  description = "this is a child module, so it return the value"
}

output "linux_vm_test_output" {
  value       = var.custom_data_script
  description = "this is a child module, so it return the value"
}
