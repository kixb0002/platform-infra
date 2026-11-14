terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.10.0"
    }
  }
}

variable "oidc_issuer_url" { type = string }
variable "redirect_uri" { type = string }
variable "owner_object_ids" { type = set(string) }

resource "azuread_application_registration" "this" {
  display_name                           = "argocd-taoufik"
  sign_in_audience                       = "AzureADMyOrg"
  implicit_access_token_issuance_enabled = false
  implicit_id_token_issuance_enabled     = false

  lifecycle {
    prevent_destroy = true
    # L'application existante a api.requestedAccessTokenVersion=null (valeur
    # API héritée), que le provider lit comme 0 mais ne permet pas de déclarer.
    # Le SSO utilise l'issuer OIDC v2 ; conserver ce champ d'API sans mutation.
    ignore_changes = [requested_access_token_version]
  }
}

resource "azuread_application_redirect_uris" "web" {
  application_id = azuread_application_registration.this.id
  type           = "Web"
  redirect_uris  = [var.redirect_uri]
  lifecycle { prevent_destroy = true }
}

resource "azuread_service_principal" "this" {
  client_id                    = azuread_application_registration.this.client_id
  account_enabled              = true
  app_role_assignment_required = false
  owners                       = var.owner_object_ids
  lifecycle { prevent_destroy = true }
}

resource "azuread_application_federated_identity_credential" "aks" {
  application_id = azuread_application_registration.this.id
  display_name   = "aks-argocd-server"
  issuer         = var.oidc_issuer_url
  subject        = "system:serviceaccount:argocd:argocd-server"
  audiences      = ["api://AzureADTokenExchange"]
  lifecycle { prevent_destroy = true }
}

output "client_id" { value = azuread_application_registration.this.client_id }
output "application_object_id" { value = azuread_application_registration.this.object_id }
