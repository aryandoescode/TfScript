terraform {
    required_providers {
        azurerm = {
            version = "3.37.0"
            source ="hashicorp/azurerm"
        }
    }
}

provider "azurerm" {
    features {

    }
}

resource "azurerm_resource_group" "demo" {
  name = "mytf-rg"
  location = "centralindia"
  tags = {
    "terraform" = "terraform"
  } 
}
resource "azurerm_virtual_network" "myvn"{
    name = "network"
    resource_group_name = azurerm_resource_group.demo.name
    location = azurerm_resource_group.demo.location
    address_space = ["10.123.0.0/16"]
}
resource "azurerm_subnet" "mysubnet" {
  name = "subnet"
  resource_group_name = azurerm_resource_group.demo.name
  virtual_network_name = azurerm_virtual_network.myvn.name
  address_prefixes = ["10.123.1.0/24"]
}

resource "azurerm_network_security_group" "mynsg" {
  name = "mynsg"
  location = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
  
  tags = {
    "terraform" = "terraform"
  }
  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_public_ip" "myip" {
  name = "myip"
  resource_group_name = azurerm_resource_group.demo.name
  location = azurerm_resource_group.demo.location
  allocation_method = "Static"
  tags = {
    "terraform" = "terraform"
  }
}
resource "azurerm_network_interface" "mynic" {
  name                = "nic"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.mysubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.myip.id
  }
}

