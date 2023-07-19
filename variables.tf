variable "container_app_environment_name" {
  type        = string
  description = "Name of the container app environment"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name to deploy to"
}

variable "location" {
  type        = string
  description = "Location of the container app environment"
}

variable "internal_load_balancer_enabled" {
  type        = bool
  default     = true
  description = "Make container app env internal only"
}

variable "subnet_name" {
  type        = string
  description = "Subnet of the container app environment"
}

variable "virtual_network_name" {
  type        = string
  description = "VNet of the container app environment"
}

variable "subnet_resource_group_name" {
  type        = string
  description = "Resource group of the subnet of the container app environment"
}

variable "certificate" {
  type = object({
    name                          = string
    version                       = optional(string)
    key_vault_name                = string
    key_vault_resource_group_name = string
    container_app_env_cert_name   = string
  })
  default     = null
  description = "Certificate for custom domain"
}

variable "dapr_components" {
  type = list(object(
    {
      name           = string
      component_type = string
      version        = optional(string, "v1")
      ignore_errors  = optional(bool, false)
      init_timeout   = optional(string, "5s")
      scopes         = optional(list(string))
      metadata = optional(list(object({
        name        = string
        secret_name = optional(string)
        value       = optional(string)
      })))
      secret = optional(object({
        name             = string
        secret_reference = string
      }))
    }
  ))
  default     = []
  description = "Dapr components to deploy"
}

variable "secrets" {
  type = map(object(
    {
      value = string
    }
  ))
  default     = {}
  sensitive   = true
  description = "Secrets for Dapr components"
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "Name of Log Analytics Workspace to send diagnostics"
}

variable "log_analytics_workspace_resource_group_name" {
  type        = string
  description = "Resource Group of Log Analytics Workspace to send diagnostics"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
}
