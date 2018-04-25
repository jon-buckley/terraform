provider "azurerm" {
  alias = "peer"

  subscription_id = "${var.peer_subscription_id}"
}

data "azurerm_subscription" "current" {}

resource "azurerm_virtual_network_peering" "local" {
  name                      = "${var.virtual_network_name}-${var.peer_virtual_network_name}-peering"
  resource_group_name       = "${var.resource_group_name}"
  virtual_network_name      = "${var.virtual_network_name}"
  remote_virtual_network_id = "/subscriptions/cfafa6b3-2176-4d7b-ae4d-73764827acc9/resourceGroups/finalta-ad/providers/Microsoft.Network/virtualNetworks/finalta-ad-vnet"

  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "peer" {
  provider = "azurerm.peer"

  name                      = "${var.peer_virtual_network_name}-${var.virtual_network_name}-peering"
  resource_group_name       = "${var.peer_resource_group_name}"
  virtual_network_name      = "${var.peer_virtual_network_name}"
  remote_virtual_network_id = "/subscriptions/cfafa6b3-2176-4d7b-ae4d-73764827acc9/resourceGroups/finalta-qa-rg/providers/Microsoft.Network/virtualNetworks/finalta-qa-vnet"

  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
}
