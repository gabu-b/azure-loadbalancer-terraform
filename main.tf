#Create a Resource Group
resource "azurerm_resource_group" "test" {
  name     = "LoadBalancerRG"
  location = "West US"
}

#Create a public IP address
resource "azurerm_public_ip" "test" {
  name                = "PublicIPForLB"
  location            = "West US"
  resource_group_name = "${azurerm_resource_group.test.name}"
  allocation_method   = "Static"
}

#Create Load Balancer and FrontEnd Address
resource "azurerm_lb" "test" {
  name                = "TestLoadBalancer"
  location            = "West US"
  resource_group_name = "${azurerm_resource_group.test.name}"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = "${azurerm_public_ip.test.id}"
  }
}

#Configure back-end address pool
resource "azurerm_lb_backend_address_pool" "test" {
  resource_group_name = "${azurerm_resource_group.test.name}"
  loadbalancer_id     = "${azurerm_lb.test.id}"
  name                = "BackEndAddressPool"
}


#Create a load balancer rule
resource "azurerm_lb_rule" "test" {
  resource_group_name            = "${azurerm_resource_group.test.name}"
  loadbalancer_id                = "${azurerm_lb.test.id}"
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
}

#Create the NAT rules
resource "azurerm_lb_nat_rule" "test" {
  resource_group_name            = "${azurerm_resource_group.test.name}"
  loadbalancer_id                = "${azurerm_lb.test.id}"
  name                           = "HTTPAccess"
  protocol                       = "Tcp"
  frontend_port                  = 4221
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}

  resource "azurerm_lb_nat_rule" "test2" {
  resource_group_name            = "${azurerm_resource_group.test.name}"
  loadbalancer_id                = "${azurerm_lb.test.id}"
  name                           = "HTTPAccess2"
  protocol                       = "Tcp"
  frontend_port                  = 4222
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}

#######Create Network Resources#######

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
    name                = "myTFVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "West US"
    resource_group_name = "${azurerm_resource_group.test.name}"
}

# Create subnet
resource "azurerm_subnet" "subnet" {
    name                 = "myTFSubnet"
    resource_group_name  = "${azurerm_resource_group.test.name}"
    virtual_network_name = "${azurerm_virtual_network.vnet.name}"
    address_prefix       = "10.0.2.0/24"
}

# Create Network Security Group and Rule for Allowing RDP Connections
resource "azurerm_network_security_group" "nsg" {
    name                = "myTFNSG"
    location            = "West US"
    resource_group_name = "${azurerm_resource_group.test.name}"

    security_rule {
        name                       = "AllowSSH"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "23"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "AllowHTTP"
        priority                   = 2000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
    name                      = "myNIC"
    location                  = "West US"
    resource_group_name       = "${azurerm_resource_group.test.name}"
    network_security_group_id = "${azurerm_network_security_group.nsg.id}"

    ip_configuration {
        name                          = "myNICConfg"
        subnet_id                     = "${azurerm_subnet.subnet.id}"
        private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_network_interface" "nic2" {
    name                      = "myNIC2"
    location                  = "West US"
    resource_group_name       = "${azurerm_resource_group.test.name}"
    network_security_group_id = "${azurerm_network_security_group.nsg.id}"

    ip_configuration {
        name                          = "myNICConfg"
        subnet_id                     = "${azurerm_subnet.subnet.id}"
        private_ip_address_allocation = "dynamic"
    }
}
