resource "azurerm_network_interface" "ni2" {
  name                      = "fin-qa-bastion-nic1"
  location                  = "westeurope"
  resource_group_name       = "${azurerm_resource_group.qa.name}"
  network_security_group_id = "${azurerm_network_security_group.secgroupbastion.id}"

  ip_configuration {
    name                          = "config2"
    subnet_id                     = "${azurerm_subnet.qa.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.publicip.id}"
  }
}

resource "azurerm_public_ip" "publicip" {
  name                         = "fin-qa-pip"
  location                     = "westeurope"
  resource_group_name          = "${azurerm_resource_group.qa.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_network_security_group" "secgroupbastion" {
  name                = "fin-qa-bastion-nsg"
  location            = "westeurope"
  resource_group_name = "${azurerm_resource_group.qa.name}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_storage_account" "storeqabastion" {
  name = "storeqabastion"

  resource_group_name = "${azurerm_resource_group.qa.name}"

  location = "westeurope"

  account_tier = "Standard"

  account_replication_type = "LRS"

  tags {
    environment = "finaltabastion"
  }
}

resource "azurerm_storage_container" "bastionhost" {
  name = "vhds"

  resource_group_name = "${azurerm_resource_group.qa.name}"

  storage_account_name = "${azurerm_storage_account.storeqabastion.name}"

  container_access_type = "private"
}

resource "azurerm_virtual_machine" "bastionvm" {
  name                  = "fin-qa-bastion-vm"
  location              = "westeurope"
  resource_group_name   = "${azurerm_resource_group.qa.name}"
  network_interface_ids = ["${azurerm_network_interface.ni2.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name = "bastionosdisk1"

    vhd_uri = "${azurerm_storage_account.storeqabastion.primary_blob_endpoint}${azurerm_storage_container.bastionhost.name}/osdisk2.vhd"

    caching = "ReadWrite"

    create_option = "FromImage"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "finqabastionvm"
    admin_username = "azureuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = "ssh-rsa - imported-openssh-key"
    }
  }

  #boot_diagnostics {
  #enabled = "false"


  #storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
  #}

  tags {
    environment = "finalta-qa"
  }
}
