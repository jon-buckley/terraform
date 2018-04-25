resource "azurerm_network_interface" "ni3" {
  name                      = "fin-qa-ssas-nic1"
  location                  = "westeurope"
  resource_group_name       = "${azurerm_resource_group.qa.name}"
  network_security_group_id = "${azurerm_network_security_group.secgroupssas.id}"

  ip_configuration {
    name                          = "config1"
    subnet_id                     = "${azurerm_subnet.qa2.id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_network_security_group" "secgroupssas" {
  name                = "fin-qa-ssas-nsg"
  location            = "westeurope"
  resource_group_name = "${azurerm_resource_group.qa.name}"

  security_rule {
    name                       = "default-allow-rdp"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_storage_account" "storessas" {
  name = "finqassastore"

  resource_group_name = "${azurerm_resource_group.qa.name}"

  location = "westeurope"

  account_tier = "Standard"

  account_replication_type = "LRS"

  tags {
    environment = "finalt-qa"
  }
}

resource "azurerm_storage_container" "storessasqa" {
  name = "vhds"

  resource_group_name = "${azurerm_resource_group.qa.name}"

  storage_account_name = "${azurerm_storage_account.storessas.name}"

  container_access_type = "private"
}

#Domain Join Extension
resource "azurerm_virtual_machine_extension" "domainjoinssas" {
  name                = "join-domain2"
  location            = "westeurope"
  resource_group_name = "${azurerm_resource_group.qa.name}"

  virtual_machine_name = "fin-qa-ssas-vm"
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.0"

  settings = <<SETTINGS
    {
        "Name": "testdomain.onmicrosoft.com",
        "OUPath": "",
        "User": "testdomain\\domainadmin",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
        "Password": "insertpassword*"
    }
PROTECTED_SETTINGS
}

# Install Microsoft Anti-Malware extension

resource "azurerm_virtual_machine_extension" "antimalware2" {
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

resource "azurerm_virtual_machine" "ssas" {
  name = "fin-qa-ssas-vm"

  location = "westeurope"

  resource_group_name = "${azurerm_resource_group.qa.name}"

  network_interface_ids = ["${azurerm_network_interface.ni3.id}"]

  vm_size = "Standard_DS2_v2"

  storage_image_reference {
    publisher = "MicrosoftSQLServer"

    offer = "SQL2017-WS2016"

    sku = "SQLDEV"

    version = "14.0.1000204"
  }

  storage_os_disk {
    name = "ssasosdisk1"

    vhd_uri = "${azurerm_storage_account.storessas.primary_blob_endpoint}${azurerm_storage_container.storessasqa.name}/osdisk1.vhd"

    caching = "ReadWrite"

    create_option = "FromImage"
  }

  # Placeholder if a SQL data disk is required 


  #storage_data_disk {
  #name = "datadisk1"


  #vhd_uri = "${azurerm_storage_account.storessas.primary_blob_endpoint}${azurerm_storage_container.cont1.name}/datadisk1.vhd"


  #disk_size_gb = "60"


  #create_option = "Empty"


  #lun = 0
  #}

  os_profile {
    computer_name = "fin-qa-ssas-vm"

    admin_username = "azureadmin"

    admin_password = "insertpassword*"
  }
  os_profile_windows_config {
    enable_automatic_upgrades = true
    provision_vm_agent        = true
  }
  tags {
    environment = "finalta-qa"
  }
}
