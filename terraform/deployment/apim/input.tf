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

variable "tags" {
  type = map(string)
}

variable "openai_uris" {
  type = list(string)
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

variable "front_door_id" {
  type = string
}
