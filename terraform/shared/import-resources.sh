#!/bin/bash
set -e

echo "🔄 Importing existing Azure resources into Terraform state..."
echo ""

# Import Resource Group
echo "1️⃣  Importing Resource Group..."
terraform import azurerm_resource_group.main \
  "/subscriptions/bbe2b149-ce14-4baf-98f5-50721df66410/resourceGroups/dev-whiskey-rg-eus"

# Import Container App Environment
echo "2️⃣  Importing Container App Environment..."
terraform import azurerm_container_app_environment.main \
  "/subscriptions/bbe2b149-ce14-4baf-98f5-50721df66410/resourceGroups/dev-whiskey-rg-eus/providers/Microsoft.App/managedEnvironments/managedEnvironment-devwhiskeyrgeus-b59d"

# Import Service Bus Namespace
echo "3️⃣  Importing Service Bus Namespace..."
terraform import azurerm_servicebus_namespace.main \
  "/subscriptions/bbe2b149-ce14-4baf-98f5-50721df66410/resourceGroups/dev-whiskey-rg-eus/providers/Microsoft.ServiceBus/namespaces/dev-whiskey-data-sb-eus"

# Import Service Bus Queue
echo "4️⃣  Importing Service Bus Queue..."
terraform import azurerm_servicebus_queue.main \
  "/subscriptions/bbe2b149-ce14-4baf-98f5-50721df66410/resourceGroups/dev-whiskey-rg-eus/providers/Microsoft.ServiceBus/namespaces/dev-whiskey-data-sb-eus/queues/whiskey-data-queue"

# Import Key Vault
echo "5️⃣  Importing Key Vault..."
terraform import azurerm_key_vault.main \
  "/subscriptions/bbe2b149-ce14-4baf-98f5-50721df66410/resourceGroups/dev-whiskey-rg-eus/providers/Microsoft.KeyVault/vaults/dev-whiskey-kv-eus"

# Import Role Assignment
echo "6️⃣  Importing Key Vault Administrator Role Assignment..."
terraform import azurerm_role_assignment.terraform_kv_admin \
  "/subscriptions/bbe2b149-ce14-4baf-98f5-50721df66410/resourceGroups/dev-whiskey-rg-eus/providers/Microsoft.KeyVault/vaults/dev-whiskey-kv-eus/providers/Microsoft.Authorization/roleAssignments/54803c5a-c7b9-e7ba-d4da-5f506a451087"

# Import Key Vault Secret
echo "7️⃣  Importing Key Vault Secret..."
terraform import azurerm_key_vault_secret.service_bus_connection \
  "https://dev-whiskey-kv-eus.vault.azure.net/secrets/dev-service-bus-connection-string"

echo ""
echo "✅ Import complete! Running terraform plan to verify..."
echo ""

terraform plan

echo ""
echo "✨ If the plan shows no changes, the import was successful!"
