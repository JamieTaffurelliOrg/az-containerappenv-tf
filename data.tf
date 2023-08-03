data "azurerm_subnet" "container_app_env_subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.subnet_resource_group_name
}

data "azurerm_key_vault_certificate" "cert" {
  for_each     = { for k in var.certificates : k.name => k if k != null }
  name         = each.value["key_vault_cert_name"]
  key_vault_id = each.value["key_vault_id"]
  version      = each.value["version"]
}

data "azurerm_log_analytics_workspace" "logs" {
  provider            = azurerm.logs
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_workspace_resource_group_name
}
