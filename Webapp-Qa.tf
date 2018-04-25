resource "random_id" "server" {
  keepers = {
    azi_id = 1
  }

  byte_length = 8
}

resource "azurerm_resource_group" "test4" {
  name     = "some-resource-group"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "fin-qa-splan"
  location            = "westeurope"
  resource_group_name = "${azurerm_resource_group.qa.name}"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "test" {
  #name                = "${random_id.server.hex}"
  name                = "fin-qa-app"
  location            = "westeurope"
  resource_group_name = "${azurerm_resource_group.qa.name}"
  app_service_plan_id = "${azurerm_app_service_plan.test.id}"

  site_config {
    dotnet_framework_version = "v4.0"
  }

  app_settings {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}
