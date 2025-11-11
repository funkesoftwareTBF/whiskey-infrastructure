terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }

  # Backend configuration for remote state
  # The key must be provided at init time since variables aren't allowed
  # Usage:
  #   terraform init -backend-config="key=shared/dev.tfstate"
  #   terraform init -backend-config="key=shared/staging.tfstate"
  #   terraform init -backend-config="key=shared/prod.tfstate"
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstatewhiskey"
    container_name       = "tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }

    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}
