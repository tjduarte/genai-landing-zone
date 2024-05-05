variable "resource_suffix" {
  type = string
}

variable "resource_group" {
  type = string
}

variable "location" {
  type = string
}

variable "name" {
  type = string
}

variable "index" {
  type = number
}

variable "oai_location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "network_resource_group" {
  type = string
}

variable "virtual_network" {
  type = object({
    id        = string,
    subnet_id = string
  })
}

variable "deployments" {
  type = list(object({
    name     = string,
    model    = string,
    version  = string,
    capacity = number
  }))
}

variable "private_dns_zone" {
  type = object({
    id   = string
    name = string
  })
}
