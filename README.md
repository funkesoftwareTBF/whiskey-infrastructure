# Shared Infrastructure

This directory contains the shared infrastructure used by all Whiskey Data Publisher services.

## What's Included

- **Resource Group**: Contains all Azure resources for the project
- **Container Apps Environment**: Shared runtime for all container apps
- **Service Bus**: Namespace and queue for message passing
- **Key Vault**: Secure storage for secrets and connection strings

## Extracting to Separate Repository

This directory is designed to be extracted to a separate repository for managing infrastructure shared across multiple projects or teams.

### Steps to Extract

1. **Create a new repository:**
   ```bash
   # Create repo on GitHub, Azure DevOps, etc.
   # Example: whiskey-shared-infrastructure
   ```

2. **Copy this directory:**
   ```bash
   # In your new repository
   git clone <new-repo-url>
   cd whiskey-shared-infrastructure
   cp -r /path/to/whiskey-data-publisher/infrastructure/terraform/shared/* .
   ```

3. **Set up remote state:**

   Edit [provider.tf](provider.tf) and uncomment the backend configuration:
   ```hcl
   backend "azurerm" {
     resource_group_name  = "terraform-state-rg"
     storage_account_name = "tfstatewhiskey"
     container_name       = "tfstate"
     key                  = "shared/${var.environment}.tfstate"
   }
   ```

4. **Deploy shared infrastructure:**
   ```bash
   terraform init
   terraform workspace new dev
   terraform plan
   terraform apply
   ```

5. **Update service repositories:**

   In each service's [main.tf](../services/breaking-bourbon-pub/main.tf), update the remote state data source:
   ```hcl
   data "terraform_remote_state" "shared" {
     backend = "azurerm"
     config = {
       resource_group_name  = "terraform-state-rg"
       storage_account_name = "tfstatewhiskey"
       container_name       = "tfstate"
       key                  = "shared/${var.environment}.tfstate"
     }
   }
   ```

6. **Remove from service repository:**
   ```bash
   # In whiskey-data-publisher repo
   git rm -r infrastructure/terraform/shared
   git commit -m "Move shared infrastructure to separate repo"
   ```

## Deploying

### First Time Setup

```bash
cd shared/

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### Updating Existing Infrastructure

```bash
cd shared/

# Pull latest changes
git pull

# Review changes
terraform plan

# Apply updates
terraform apply
```

## Outputs

This module exports several outputs that services can consume:

- `resource_group_name` / `resource_group_id`
- `container_app_environment_id` / `container_app_environment_name`
- `service_bus_namespace_id` / `service_bus_namespace_name`
- `service_bus_queue_name` / `service_bus_queue_id`
- `key_vault_id` / `key_vault_name` / `key_vault_uri`
- `service_bus_connection_secret_name`
- `environment` / `project_name` / `location`

Services can access these via remote state or pass them as variables.

## Variables

Key variables you can customize:

- `environment` - dev, staging, or prod (default: dev)
- `location` - Azure region (default: eastus)
- `project_name` - Project name for resource naming (default: whiskey)
- `tags` - Common tags to apply to all resources

## Multiple Environments

Use Terraform workspaces to manage multiple environments:

```bash
# Create and switch to staging workspace
terraform workspace new staging
terraform apply -var="environment=staging"

# Switch back to dev
terraform workspace select dev

# List workspaces
terraform workspace list
```

## Security Considerations

1. **Key Vault Access**: Uses RBAC instead of access policies
2. **Network ACLs**: Production Key Vault denies public access by default
3. **Soft Delete**: Enabled with 90-day retention
4. **Service Bus**: Standard tier with dead-letter queue enabled

## Cost Optimization

Current configuration uses:
- **Standard tier** Service Bus (~$10/month)
- **Standard** Key Vault ($0.03 per 10,000 operations)
- **Consumption** Container Apps Environment ($0 when idle)

## Monitoring

Consider adding:
- Log Analytics workspace for Container Apps
- Application Insights for monitoring
- Alerts for Key Vault access failures
- Service Bus queue depth monitoring

## Related Documentation

- [Main README](../README.md) - Overview of entire infrastructure
- [MIGRATION.md](../MIGRATION.md) - Migration from monolithic structure
- [Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/)
