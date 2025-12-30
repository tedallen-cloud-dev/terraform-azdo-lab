terraform {
  required_version = ">= 1.5.0"

  # Your Azure DevOps pipeline passes the backend values during `terraform init`
  # (resource group, storage account, container, key). This empty block enables
  # the AzureRM backend so those values can be applied.
  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

############################################
# Minimal test deployment
# (This gives `plan`/`apply` something real to do.)
############################################

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Resource group name to create/manage"
  type        = string
  default     = "rg-terraform-azdo-lab"
}

variable "vnet_name" {
  description = "Virtual network name"
  type        = string
  default     = "vnet-terraform-azdo-lab"
}

variable "vnet_address_space" {
  description = "Address space for the VNet"
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "subnets" {
  description = "Map of subnet name to CIDR prefix"
  type        = map(string)
  default = {
    "subnet-app" = "10.10.1.0/24"
    "subnet-db"  = "10.10.2.0/24"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.vnet_address_space
}

resource "azurerm_subnet" "subnet" {
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value]
}

output "resource_group_id" {
  value = azurerm_resource_group.rg.id
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnet_ids" {
  value = { for k, s in azurerm_subnet.subnet : k => s.id }
}
