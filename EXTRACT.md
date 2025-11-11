# Extracting Shared Infrastructure - Quick Guide

This is a quick reference for extracting the `shared/` directory to a separate repository.

## Why Extract?

- **Separation of concerns**: Infrastructure vs application code
- **Different lifecycles**: Shared infra changes less frequently than services
- **Team boundaries**: Platform team owns shared, service teams own services
- **Reusability**: Share infrastructure across multiple projects
- **Security**: Different access controls for infrastructure

## Quick Extraction Steps

### 1. Create New Repository

```bash
# On GitHub, Azure DevOps, etc., create:
# whiskey-shared-infrastructure
```

### 2. Copy Files

```bash
# Clone new repo
git clone <new-repo-url> whiskey-shared-infrastructure
cd whiskey-shared-infrastructure

# Copy shared infrastructure files
cp -r <whiskey-data-publisher-path>/infrastructure/terraform/shared/* .

# Initial commit
git add .
git commit -m "Initial commit: Shared infrastructure"
git push origin main
```

### 3. Set Up Remote State

Create Azure Storage for Terraform state:

```bash
az group create --name terraform-state-rg --location eastus

az storage account create \
  --name tfstatewhiskey \
  --resource-group terraform-state-rg \
  --location eastus \
  --sku Standard_LRS

az storage container create \
  --name tfstate \
  --account-name tfstatewhiskey
```

### 4. Configure Backend

Uncomment in `provider.tf`:

```hcl
backend "azurerm" {
  resource_group_name  = "terraform-state-rg"
  storage_account_name = "tfstatewhiskey"
  container_name       = "tfstate"
  key                  = "shared/dev.tfstate"
}
```

### 5. Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 6. Update Service Repositories

In `whiskey-data-publisher/infrastructure/terraform/services/*/main.tf`:

The `data "terraform_remote_state" "shared"` block is already configured!
Just uncomment it and ensure the backend config matches your storage account.

### 7. Test Service Deployment

```bash
cd <whiskey-data-publisher-path>/infrastructure/terraform/services/breaking-bourbon-pub
terraform init
terraform plan  # Should use remote state to find shared resources
terraform apply
```

### 8. Clean Up Original Repo

```bash
cd <whiskey-data-publisher-path>
git rm -r infrastructure/terraform/shared
git commit -m "Extract shared infrastructure to separate repo"
git push
```

## Directory Structure After Extraction

**whiskey-shared-infrastructure/**
```
.
├── README.md
├── EXTRACT.md
├── data.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── provider.tf
├── variables.tf
└── .github/
    └── workflows/
        └── terraform.yml  # CI/CD for shared infra
```

**whiskey-data-publisher/infrastructure/terraform/**
```
.
├── README.md
├── MIGRATION.md
├── modules/
│   └── container-app/
├── services/
│   ├── breaking-bourbon-pub/
│   └── whiskey-reviewer-pub/
└── .github/
    └── workflows/
        └── deploy-services.yml  # CI/CD for services
```

## Using Remote State

Services automatically reference shared infrastructure:

```hcl
# In services/*/main.tf - already configured!
data "terraform_remote_state" "shared" {
  backend = "azurerm"
  config = {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstatewhiskey"
    container_name       = "tfstate"
    key                  = "shared/${var.environment}.tfstate"
  }
}

locals {
  # Automatically uses remote state outputs
  resource_group_name = data.terraform_remote_state.shared.outputs.resource_group_name
  key_vault_id        = data.terraform_remote_state.shared.outputs.key_vault_id
  # ... etc
}
```

## Multiple Environments

Use Terraform workspaces in the shared infrastructure repo:

```bash
# In whiskey-shared-infrastructure/
terraform workspace new staging
terraform apply -var="environment=staging"

terraform workspace new prod
terraform apply -var="environment=prod"
```

Services reference the correct state file via `${var.environment}` in the key.

## CI/CD Example

**Shared Infrastructure** (whiskey-shared-infrastructure/.github/workflows/terraform.yml):
```yaml
name: Deploy Shared Infrastructure

on:
  push:
    branches: [main]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
      - run: terraform init
      - run: terraform plan
      - run: terraform apply -auto-approve
```

**Service Deployment** (whiskey-data-publisher/.github/workflows/deploy-services.yml):
```yaml
name: Deploy Services

on:
  push:
    paths:
      - 'src/**'
      - 'infrastructure/terraform/services/**'

jobs:
  deploy-service:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        service: [breaking-bourbon-pub, whiskey-reviewer-pub]
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
      - working-directory: infrastructure/terraform/services/${{ matrix.service }}
        run: |
          terraform init
          terraform plan
          terraform apply -auto-approve
```

## Rollback

If you need to rollback the extraction:

```bash
# Copy shared back to original repo
cd <whiskey-data-publisher-path>/infrastructure/terraform
git checkout <commit-before-extraction> -- shared/

# Remove remote state data source from services
# (comment out data "terraform_remote_state" blocks)

# Re-deploy with local state
terraform init
terraform plan
terraform apply
```

## Benefits Achieved

✅ **Independent versioning** - Shared infra has its own repo/tags
✅ **Separate CI/CD** - Different pipelines for infra vs services
✅ **Clear ownership** - Platform team owns shared, service teams own services
✅ **State isolation** - Separate state files reduce blast radius
✅ **Reusability** - Other projects can use the same shared infra
✅ **Faster service deploys** - Don't need to plan entire infrastructure

## Questions?

See [README.md](./README.md) for detailed documentation or [MIGRATION.md](../MIGRATION.md) for migration from monolithic structure.
