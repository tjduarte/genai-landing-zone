terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.102.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.3"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {
  }
}

provider "external" {
}
