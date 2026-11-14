terraform {
  backend "local" {}
  required_version = ">= 1.9, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.13.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.10.0"
    }
  }
}

variable "subscription_id" { type = string }
variable "resource_group_name" {
  type    = string
  default = "RG-Taoufik-Mellah"
  validation {
    condition     = var.resource_group_name == "RG-Taoufik-Mellah"
    error_message = "Cette configuration est limitée au groupe autorisé."
  }
}
variable "cluster_name" {
  type    = string
  default = "aks-taoufik-lab"
}
variable "enable_key_vault" {
  type        = bool
  default     = false
  description = "Activer seulement après validation du chemin réseau privé et des droits DNS/subnet."
}

provider "azurerm" {
  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

provider "azuread" {
  tenant_id = data.azurerm_client_config.current.tenant_id
}

data "azurerm_client_config" "current" {}
data "azurerm_resource_group" "existing" { name = var.resource_group_name }
data "azurerm_kubernetes_cluster" "existing" {
  name                = var.cluster_name
  resource_group_name = data.azurerm_resource_group.existing.name
}

locals {
  suffix = substr(sha256("${var.subscription_id}/${var.resource_group_name}"), 0, 8)
}

module "acr" {
  source              = "../../modules/acr"
  name                = "tmgitops${local.suffix}"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
}

module "key_vault" {
  count               = var.enable_key_vault ? 1 : 0
  source              = "../../modules/key-vault"
  name                = "kv-tm-gitops-${local.suffix}"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.id
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_kubernetes_cluster.existing.kubelet_identity[0].object_id
  principal_type       = "ServicePrincipal"
}

output "acr_login_server" { value = module.acr.login_server }
output "key_vault_uri" { value = try(module.key_vault[0].uri, null) }
output "existing_aks_id" { value = data.azurerm_kubernetes_cluster.existing.id }
