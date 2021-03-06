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

  tenant_id = ""

  access_policy {
    tenant_id = ""
    object_id = ""

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
