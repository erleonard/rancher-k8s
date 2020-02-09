

variable "azure_subscriptionId" {
    description = "Azure subscription Id"
    default = ""
}
variable "azure_clientId" {
    description = "Azure client id or also known as app id"
    default = ""
}
variable "azure_clientSecret" {
    description = "Azure client secret/password to be provided at runtime"
}
variable "azure_tenantId" {
    description = "Azure active directory tenant id"
    default = ""
}

variable "prefix" {
    description = "Prefix name for all azure resources"
    default = "rancher"
}

variable "azure_location" {
    description = "Azure resource location"
    default = "eastus2"
}

variable "azure_tags" {
  description = "The tags to associate with your network and subnets."
  type        = map

  default = {
    environment  = "demo"
    owner = "cloudCanucks"
  }
}

variable "vm_username" {
    description = "Virtual machine administrator user name"
    default = "azureadmin"
}
variable "vm_password" {
    description = "Virtual machine administrator password"
}