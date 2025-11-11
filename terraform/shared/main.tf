# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.environment}-${var.project_name}-rg-${local.location_short}"
  location = var.location

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

# Container Apps Environment - without Log Analytics to match existing config
resource "azurerm_container_app_environment" "main" {
  name                = "managedEnvironment-${var.environment}${var.project_name}rg${local.location_short}-b59d"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

# Service Bus Namespace
resource "azurerm_servicebus_namespace" "main" {
  name                = "${var.environment}-${var.project_name}-data-sb-${local.location_short}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

# Service Bus Queue
resource "azurerm_servicebus_queue" "main" {
  name         = "whiskey-data-queue"
  namespace_id = azurerm_servicebus_namespace.main.id

  max_size_in_megabytes                = 1024
  default_message_ttl                  = "P14D"
  lock_duration                        = "PT5M"
  dead_lettering_on_message_expiration = true
  max_delivery_count                   = 10
}

# Key Vault
resource "azurerm_key_vault" "main" {
  name                       = "${var.environment}-${var.project_name}-kv-${local.location_short}"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 90
  purge_protection_enabled   = false
  enable_rbac_authorization  = true  # Using RBAC instead of access policies

  network_acls {
    default_action = var.environment == "prod" ? "Deny" : "Allow"
    bypass         = "AzureServices"
  }

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

# Grant Terraform (current user) access to Key Vault using RBAC
resource "azurerm_role_assignment" "terraform_kv_admin" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Store Service Bus connection string in Key Vault
resource "azurerm_key_vault_secret" "service_bus_connection" {
  name         = "${var.environment}-service-bus-connection-string"
  value        = azurerm_servicebus_namespace.main.default_primary_connection_string
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_role_assignment.terraform_kv_admin
  ]
}
