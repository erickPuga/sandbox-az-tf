########### TEST INSIGHTS ############

resource "azurerm_resource_group" "test-insights-rg" {
  name     = "rg-test-insights"
  location = "eastus2"
}

resource "azurerm_virtual_network" "test-vnet" {
  name                = "test-vnet"
  address_space       = ["10.21.0.0/16"]
  location            = azurerm_resource_group.test-insights-rg.location
  resource_group_name = azurerm_resource_group.test-insights-rg.name
}
resource "azurerm_subnet" "test-insights-subnet" {
  name                 = "subnet-test-insights"
  resource_group_name  = azurerm_resource_group.test-insights-rg.name
  virtual_network_name = azurerm_virtual_network.test-vnet.name
  address_prefixes     = ["10.21.2.0/24"]
}

resource "azurerm_log_analytics_workspace" "wks" {
  name                = "wks-insights-test01"
  location            = azurerm_resource_group.test-insights-rg.location
  resource_group_name = azurerm_resource_group.test-insights-rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_storage_account" "stracc" {
  name                     = "insightsteststracc001"
  resource_group_name      = azurerm_resource_group.test-insights-rg.name
  location                 = azurerm_resource_group.test-insights-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_log_analytics_data_export_rule" "der_insighst-test" {
  name                    = "dataExport1"
  resource_group_name     = azurerm_resource_group.test-insights-rg.name
  workspace_resource_id   = azurerm_log_analytics_workspace.wks.id
  destination_resource_id = azurerm_storage_account.stracc.id
  table_names             = ["Heartbeat"]
  enabled                 = true
}

module "compute" {
  source  = "Azure/compute/azurerm"
  version = "3.14.0"
  resource_group_name = azurerm_resource_group.test-insights-rg.name
  vnet_subnet_id      = azurerm_subnet.test-insights-subnet.id
  vm_os_publisher                  = "Canonical"
  vm_os_offer                      = "UbuntuServer"
  vm_os_sku                        = "18.04-LTS"
  vm_size                          = "Standard_B1ls"
}

module "windowsservers" {
  source              = "Azure/compute/azurerm"
  resource_group_name = azurerm_resource_group.test-insights-rg.name
  is_windows_image    = true
  vm_hostname         = "mywinvm" // line can be removed if only one VM module per resource group
  admin_password      = "ComplxP@ssw0rd!"
  vm_os_simple        = "WindowsServer"
  vnet_subnet_id      = azurerm_subnet.test-insights-subnet.id
  vm_os_publisher               = "MicrosoftWindowsServer"
  vm_os_offer                   = "WindowsServer"
  vm_os_sku                     = "2012-R2-Datacenter"
  vm_size                       = "Standard_DS2_V2"

}