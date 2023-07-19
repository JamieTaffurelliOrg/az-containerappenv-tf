data "azurerm_subnet" "container_app_env_subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.subnet_resource_group_name
}

data "azurerm_key_vault" "cert_key_vault" {
  for_each            = var.certificate == null ? [] : [var.certificate]
  name                = var.certificate.key_vault_name
  resource_group_name = var.certificate.key_vault_resource_group_name
}

data "azurerm_key_vault_certificate" "cert" {
  for_each     = var.certificate == null ? [] : [var.certificate]
  name         = var.certificate.name
  key_vault_id = data.azurerm_key_vault.cert_key_vault[0].id
  version      = var.certificate.version
}

data "azurerm_log_analytics_workspace" "logs" {
  provider            = azurerm.logs
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_workspace_resource_group_name
}
