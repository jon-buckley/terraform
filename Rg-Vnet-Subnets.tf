resource "azurerm_resource_group" "qa" {
  name     = "finalta-qa-rg"
  location = "westeurope"
}

resource "azurerm_virtual_network" "qa" {
  name                = "finalta-qa-vnet"
  address_space       = ["10.2.0.0/16"]
  location            = "${azurerm_resource_group.qa.location}"
  resource_group_name = "${azurerm_resource_group.qa.name}"
  dns_servers         = ["10.1.0.4", "10.1.0.5"]
}

resource "azurerm_subnet" "qa" {
  name                 = "qa-sub-external"
  resource_group_name  = "${azurerm_resource_group.qa.name}"
  virtual_network_name = "${azurerm_virtual_network.qa.name}"
  address_prefix       = "10.2.0.0/24"
}

resource "azurerm_subnet" "qa2" {
  name                 = "qa-sub-internal"
  resource_group_name  = "${azurerm_resource_group.qa.name}"
  virtual_network_name = "${azurerm_virtual_network.qa.name}"
  address_prefix       = "10.2.1.0/24"
}



