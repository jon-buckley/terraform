resource "azurerm_network_interface" "ni1" {
  name                      = "fin-qa-gateway-nic1"
  location                  = "westeurope"
  resource_group_name       = "${azurerm_resource_group.qa.name}"
  network_security_group_id = "${azurerm_network_security_group.secgroup.id}"

  ip_configuration {
    name                          = "config1"
    subnet_id                     = "${azurerm_subnet.qa2.id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_network_security_group" "secgroup" {
  name                = "fin-qa-gateway-nsg"
  location            = "westeurope"
  resource_group_name = "${azurerm_resource_group.qa.name}"

  security_rule {
    name                       = "default-allow-rdp"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_storage_account" "storevm123" {
  name = "finqagatewaystore"

  resource_group_name = "${azurerm_resource_group.qa.name}"

  location = "westeurope"

  account_tier = "Standard"

  account_replication_type = "LRS"

  tags {
    environment = "finalt-qa"
  }
}

resource "azurerm_storage_container" "cont1" {
  name = "vhds"

  resource_group_name = "${azurerm_resource_group.qa.name}"

  storage_account_name = "${azurerm_storage_account.storevm123.name}"

  container_access_type = "private"
}

#Domain Join Extension
resource "azurerm_virtual_machine_extension" "domainjoingate" {
  name                = "join-domain"
  location            = "westeurope"
  resource_group_name = "${azurerm_resource_group.qa.name}"

  virtual_machine_name = "fin-qa-gate-vm"
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.0"

  settings = <<SETTINGS
    {
        "Name": "finaltadev.onmicrosoft.com",
        "OUPath": "",
        "User": "finaltadev\\domainadmin",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
        "Password": "Sorcerer778*"
    }
PROTECTED_SETTINGS
}

# Install Microsoft Anti-Malware extension

resource "azurerm_virtual_machine_extension" "antimalware" {
  name                = "antimalware"
  location            = "westeurope"
  resource_group_name = "${azurerm_resource_group.qa.name}"

  virtual_machine_name       = "fin-qa-gate-vm"
  publisher                  = "Microsoft.Azure.Security"
  type                       = "IaaSAntimalware"
  type_handler_version       = "1.1"
  auto_upgrade_minor_version = "true"

  settings = <<SETTINGS
    {
        "AntimalwareEnabled": true,
        "RealtimeProtectionEnabled": "true",
        "ScheduledScanSettings": {
            "isEnabled": "true",
            "day": "1",
            "time": "120",
            "scanType": "Quick"
            },
        "Exclusions": {
            "Extensions": "",
            "Paths": "",
            "Processes": ""
            }
    }
SETTINGS

  tags {
    environment = "finalta-qa"
  }
}

resource "azurerm_virtual_machine" "vm1" {
  name = "fin-qa-gate-vm"

  location = "westeurope"

  resource_group_name = "${azurerm_resource_group.qa.name}"

  network_interface_ids = ["${azurerm_network_interface.ni1.id}"]

  vm_size = "Standard_DS2_v2"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"

    offer = "WindowsServer"

    sku = "2016-Datacenter"

    version = "latest"
  }

  storage_os_disk {
    name = "gateosdisk1"

    vhd_uri = "${azurerm_storage_account.storevm123.primary_blob_endpoint}${azurerm_storage_container.cont1.name}/osdisk1.vhd"

    caching = "ReadWrite"

    create_option = "FromImage"
  }

  os_profile {
    computer_name = "fin-qa-gate-vm"

    admin_username = "azureuser"

    admin_password = "Sorcerer778*"
  }

  os_profile_windows_config {
    enable_automatic_upgrades = true
    provision_vm_agent        = true
  }

  tags {
    environment = "finalta-qa"
  }
}
