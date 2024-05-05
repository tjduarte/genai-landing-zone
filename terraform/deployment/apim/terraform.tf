terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.102.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "1.13.1"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {
  }
}
