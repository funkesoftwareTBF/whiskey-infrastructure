# Resource Group outputs
output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "location" {
  description = "The Azure region where resources are deployed"
  value       = azurerm_resource_group.main.location
}

# Container Apps Environment outputs
output "container_app_environment_id" {
  description = "The ID of the Container Apps Environment"
  value       = azurerm_container_app_environment.main.id
}

output "container_app_environment_name" {
  description = "The name of the Container Apps Environment"
  value       = azurerm_container_app_environment.main.name
}

# Service Bus outputs
output "service_bus_namespace_id" {
  description = "The ID of the Service Bus Namespace"
  value       = azurerm_servicebus_namespace.main.id
}

output "service_bus_namespace_name" {
  description = "The name of the Service Bus Namespace"
  value       = azurerm_servicebus_namespace.main.name
}

output "service_bus_queue_name" {
  description = "The name of the Service Bus Queue"
  value       = azurerm_servicebus_queue.main.name
}

output "service_bus_queue_id" {
  description = "The ID of the Service Bus Queue"
  value       = azurerm_servicebus_queue.main.id
}

# Key Vault outputs
output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "service_bus_connection_secret_name" {
  description = "The name of the Key Vault secret containing the Service Bus connection string"
  value       = azurerm_key_vault_secret.service_bus_connection.name
}

# Additional useful outputs
output "environment" {
  description = "The environment name"
  value       = var.environment
}

output "project_name" {
  description = "The project name"
  value       = var.project_name
}
