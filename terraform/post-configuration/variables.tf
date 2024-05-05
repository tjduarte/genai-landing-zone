variable "resource_suffix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group" {
  type = object({
    name = string
  })
}

variable "network_resource_group" {
  type = object({
    name = string
  })
}

variable "open_ai" {
  type = object({
    name      = string
    locations = list(string)
  })
}

variable "storage" {
  type = object({
    name           = string,
    container_name = string
  })
}

variable "ai_search" {
  type = object({
    name        = string,
    api_version = string
  })
}

variable "apim" {
  type = object({
    name = string
  })
}

variable "tags" {
  type = map(string)
}

variable "virtual_network" {
  type = object({
    name          = string,
    address_space = list(string)
    subnets = object({
      ai   = string,
      apim = string,
      vm   = string
    })
  })
}

variable "virtual_machine" {
  type = object({
    name = string
  })
}
