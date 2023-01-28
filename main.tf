resource "azurerm_resource_group" "terrarg" {
  name     = var.resource_group_name
  location = "westeurope"
}

resource "azurerm_virtual_network" "terraVNET" {
  address_space       = ["11.0.0.0/16"]
  resource_group_name = azurerm_resource_group.terrarg.name
  location            = azurerm_resource_group.terrarg.location
  name                = var.virtual_network_name
}

resource "azurerm_subnet" "terraSubnet" {
  name                 = var.subnet_name
  address_prefixes     = ["11.0.0.0/24"]
  virtual_network_name = azurerm_virtual_network.terraVNET.name
  resource_group_name  = azurerm_resource_group.terrarg.name
  service_endpoints = [ "Microsoft.Storage" ]
}

resource "azurerm_network_security_group" "terraNSG" {
  name                = var.nsg_name
  resource_group_name = azurerm_resource_group.terrarg.name
  location            = azurerm_resource_group.terrarg.location
  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_app_service" "terrawebapp" {
  name                = var.web_app_name
  resource_group_name = azurerm_resource_group.terrarg.name
  location            = azurerm_resource_group.terrarg.location
  app_service_plan_id = azurerm_app_service_plan.name.id
}

resource "azurerm_app_service_plan" "name" {
  name                = var.app_service_plan_name
  resource_group_name = azurerm_resource_group.terrarg.name
  location            = azurerm_resource_group.terrarg.location
  sku {
    size = "F1"
    tier = "Free"
  }
}

resource "azurerm_storage_account_network_rules" "terstoaccrules" {
  storage_account_id = azurerm_storage_account.terrastorage.id

  default_action             = "Allow"
  ip_rules                   = ["127.0.0.1"]
  virtual_network_subnet_ids = [azurerm_subnet.terraSubnet.id]
  bypass                     = ["Metrics"]
}

resource "azurerm_storage_account" "terrastorage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.terrarg.name
  location                 = azurerm_resource_group.terrarg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_private_dns_zone" "terrapvtdnszone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.terrarg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "terraPvtLink" {
  name                  = var.private_link_name
  resource_group_name   = azurerm_resource_group.terrarg.name
  private_dns_zone_name = azurerm_private_dns_zone.terrapvtdnszone.name
  virtual_network_id    = azurerm_virtual_network.terraVNET.id
}

resource "azurerm_private_endpoint" "terrapvtep" {
  name                = var.private_endpoint_name
  resource_group_name = azurerm_resource_group.terrarg.name
  location            = azurerm_resource_group.terrarg.location
  subnet_id           = azurerm_subnet.terraSubnet.id

  private_service_connection {
    name                           = "terrastorage_pvtep"
    private_connection_resource_id = azurerm_storage_account.terrastorage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

resource "azurerm_private_dns_a_record" "terraPvtDnsARecord" {
  name                = "terrapvtdnsarc"
  zone_name           = azurerm_private_dns_zone.terrapvtdnszone.name
  resource_group_name = azurerm_resource_group.terrarg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.terrapvtep.private_service_connection.0.private_ip_address]
}


