output "a_open_ai_endpoint_name_hosts_file_entry" {
  value       = "${azurerm_private_endpoint.oai-srv-pe.private_service_connection[0].private_ip_address} ${azurerm_cognitive_account.aviatrix-ignite.custom_subdomain_name}.openai.azure.com"
  description = "The hosts file entry to access the OpenAI endpoint privately."
}

output "b_ai_search_name_hosts_file_entry" {
  value       = "${azurerm_private_endpoint.oai-search-srv-pe.private_service_connection[0].private_ip_address} ${azurerm_search_service.aviatrix-ignite-search.name}.search.windows.net"
  description = "The hosts file entry to access the AI Search endpoint privately."
}

output "c_storage_account_hosts_file_entry" {
  value       = "${azurerm_private_endpoint.avx-ignite-sa-pe.private_service_connection[0].private_ip_address} ${azurerm_storage_account.avx-ignite-sa.name}.blob.core.windows.net"
  description = "The hosts file entry to access the Storage Account privately."
}

output "d_aws_instance_private_ip" {
  value       = module.ec2_instance_linux.private_ip
  description = "The private IP address of the AWS EC2 instance."
}

output "e_private_dns_resolver_inbound_endpoint_ip" {
  value       = azurerm_private_dns_resolver_inbound_endpoint.dns-inbound.ip_configurations[0].private_ip_address
  description = "The private IP address of the DNS resolver inbound endpoint."
}

output "f_private_endpoint_open_ai_ip" {
  value       = azurerm_private_endpoint.oai-srv-pe.private_service_connection[0].private_ip_address
  description = "The endpoint IP of the OpenAI service private endpoint."
}
