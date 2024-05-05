terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.101.0"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "1.19.1"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {
  }
}

provider "restapi" {
  uri                  = "https://${data.azurerm_search_service.ai_search.name}.search.windows.net"
  write_returns_object = true
  debug                = true

  headers = {
    "api-key"      = data.azurerm_search_service.ai_search.primary_key,
    "Content-Type" = "application/json"
  }

  create_method  = "POST"
  update_method  = "PUT"
  destroy_method = "DELETE"
}
