terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "main" {
  name = "LV21_AnnDavey_Workshop_M12_Pt2"
}

resource "azurerm_app_service_plan" "main" {
  name                = "ann-plan1-terraformed-asp"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "main" {
  name                = "ann-example-app"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name  
  app_service_plan_id     = azurerm_app_service_plan.main.id

site_config {
    app_command_line = ""
    linux_fx_version = "DOCKER|corndelldevopscourse/mod12app:latest"
  }

  app_settings = {
    "SCM_DO_BUILD_DURING_DEPLOYMENT" : "True"
    "DEPLOYMENT_METHOD" : "Terraform"
    "CONNECTION_STRING" : "...Password=${var.database_password};..."
  }
}
 
resource "azurerm_sql_server" "main" {
  name                         = "anndavey-non-iac-sqlserver"
  resource_group_name          = data.azurerm_resource_group.main.name
  location                     = data.azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = "dbadmin"
  administrator_login_password = var.database_password
}

resource "azurerm_sql_database" "main" {
  name                = "anndavey-non-iac-db"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  server_name         = azurerm_sql_server.main.name
  edition             = "Basic"
}
