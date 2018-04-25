#resource "azurerm_resource_group" "qa" {
#name     = "finalta-dev"
#location = "westeurope"
#}

resource "azurerm_key_vault" "qa" {
  name                = "fin-qa-vault"
  location            = "westeurope"
  resource_group_name = "${azurerm_resource_group.qa.name}"

  sku {
    name = "standard"
  }

  tenant_id = "7c9cf998-b8a1-4ec3-a174-976070a2e116"

  access_policy {
    tenant_id = "7c9cf998-b8a1-4ec3-a174-976070a2e116"
    object_id = "54123340-0e2e-4239-886d-32f7bf6f3a58"

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get",
    ]
  }

  enabled_for_disk_encryption = true

  tags {
    environment = "finalta-qa"
  }
}
