# Configure the Microsoft Azure Provider
provider "azurerm" {
    subscription_id = var.azure_subscriptionId
    client_id       = var.azure_clientId
    client_secret   = var.azure_clientSecret
    tenant_id       = var.azure_tenantId
}

data "template_file" "cloudconfig" {
    template = "${file("${path.module}/cloudconfig.tpl")}"
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.cloudconfig.rendered}"
  }
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "myterraformgroup" {
    name     = "${var.prefix}-Rg"
    location = var.azure_location

    tags = var.azure_tags
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "${var.prefix}-Vnet"
    location            = var.azure_location
    resource_group_name = azurerm_resource_group.myterraformgroup.name
    address_space       = ["10.0.0.0/16"]

    tags = var.azure_tags
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "default"
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "${var.prefix}-VmPip"
    location                     = var.azure_location
    resource_group_name          = azurerm_resource_group.myterraformgroup.name
    allocation_method            = "Dynamic"

    tags = var.azure_tags
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name                      = "${var.prefix}-VmNic"
    location                  = var.azure_location
    resource_group_name       = azurerm_resource_group.myterraformgroup.name

    ip_configuration {
        name                          = "config1"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
    }

    tags = var.azure_tags
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.myterraformgroup.name
    }
    
    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.myterraformgroup.name
    location                    = var.azure_location
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = var.azure_tags
}

# Create virtual machine
resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = "${var.prefix}-Vm"
    location              = azurerm_resource_group.myterraformgroup.location
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
    vm_size               = "Standard_DS3_v2"

    storage_os_disk {
        name              = "${var.prefix}-Vm-OsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "${var.prefix}-Vm"
        admin_username = var.vm_username
        admin_password = var.vm_password
        custom_data    = data.template_cloudinit_config.config.rendered
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = var.azure_tags
}