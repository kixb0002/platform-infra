variable "enable_ci_identity" {
  type    = bool
  default = false
}

resource "azurerm_user_assigned_identity" "ecommerce_ci" {
  count               = var.enable_ci_identity ? 1 : 0
  name                = "id-ecommerce-ci-lab"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  lifecycle { prevent_destroy = true }
}

resource "azurerm_federated_identity_credential" "ecommerce_main" {
  count                     = var.enable_ci_identity ? 1 : 0
  name                      = "github-ecommerce-main"
  user_assigned_identity_id = azurerm_user_assigned_identity.ecommerce_ci[0].id
  issuer                    = "https://token.actions.githubusercontent.com"
  audience                  = ["api://AzureADTokenExchange"]
  subject                   = "repo:kixb0002@179703503/ecommerce-app@1457973761:ref:refs/heads/main"
  lifecycle { prevent_destroy = true }
}

resource "azurerm_role_assignment" "ecommerce_ci_acr_push" {
  count                = var.enable_ci_identity ? 1 : 0
  scope                = module.acr.id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_user_assigned_identity.ecommerce_ci[0].principal_id
  principal_type       = "ServicePrincipal"
  lifecycle { prevent_destroy = true }
}

output "ecommerce_ci_client_id" {
  value = try(azurerm_user_assigned_identity.ecommerce_ci[0].client_id, null)
}
