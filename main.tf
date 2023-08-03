/*resource "azurerm_container_app_environment" "container_app_env" {
  name                           = var.container_app_environment_name
  location                       = var.location
  resource_group_name            = var.resource_group_name
  infrastructure_subnet_id       = data.azurerm_subnet.container_app_env_subnet.id
  internal_load_balancer_enabled = var.internal_load_balancer_enabled
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.logs.id

  tags = var.tags
}*/

resource "azapi_resource" "container_app_env" {
  type      = "Microsoft.App/managedEnvironments@2022-11-01-preview"
  name      = var.container_app_environment_name
  parent_id = data.azurerm_resource_group.resource_group.id
  location  = var.location
  tags      = var.tags

  body = jsonencode({
    properties = {
      appLogsConfiguration = {
        destination = "log-analytics"
        logAnalyticsConfiguration = {
          customerId = data.azurerm_log_analytics_workspace.logs.workspace_id
          sharedKey  = data.azurerm_log_analytics_workspace.logs.primary_shared_key
        }
      }
      "infrastructureResourceGroup" = var.infrastructure_resource_group
      vnetConfiguration = {
        "internal"               = var.internal_load_balancer_enabled
        "infrastructureSubnetId" = data.azurerm_subnet.container_app_env_subnet.id
      }
      workloadProfiles = [
        {
          name                = "Consumption"
          workloadProfileType = "Consumption"
          maximumCount        = var.maximum_count
          maximumCount        = var.minimum_count
        }
      ]
    }
  })
}

resource "azurerm_container_app_environment_certificate" "container_app_env_cert" {
  for_each                     = { for k in var.certificates : k.name => k if k != null }
  name                         = each.key
  container_app_environment_id = azapi_resource.container_app_env.id
  certificate_blob_base64      = data.azurerm_key_vault_certificate.cert[(each.key)].certificate_data_base64
  certificate_password         = ""
}

resource "azurerm_container_app_environment_dapr_component" "dapr_component" {
  for_each                     = { for k in var.dapr_components : k.name => k if k != null }
  name                         = each.key
  container_app_environment_id = azapi_resource.container_app_env.id
  component_type               = each.value["component_type"]
  version                      = each.value["version"]
  ignore_errors                = each.value["ignore_errors"]
  init_timeout                 = each.value["init_timeout"]
  scopes                       = each.value["scopes"]

  dynamic "metadata" {
    for_each = { for k in each.value["metadata"] : k.name => k }

    content {
      name        = metadata.key
      secret_name = metadata.value["secret_name"]
      value       = metadata.value["value"]
    }
  }

  dynamic "secret" {
    for_each = each.value["secret"] == null ? [] : [each.value["secret"]]

    content {
      name  = secret.value["name"]
      value = var.secrets[(secret.value["secret_reference"])].value
    }
  }
}
