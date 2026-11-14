# Adoption des identités LAB existantes ; IDs de ressources, aucun secret.

import {
  to = module.argocd_sso.azuread_application_registration.this
  id = "/applications/d25bce1e-3f33-4c29-ab03-5ff18731fda2"
}

import {
  to = module.argocd_sso.azuread_application_redirect_uris.web
  id = "/applications/d25bce1e-3f33-4c29-ab03-5ff18731fda2/redirectUris/Web"
}

import {
  to = module.argocd_sso.azuread_service_principal.this
  id = "/servicePrincipals/acb03f7a-0302-48a5-bec9-6c26091b79a1"
}

import {
  to = module.argocd_sso.azuread_application_federated_identity_credential.aks
  id = "d25bce1e-3f33-4c29-ab03-5ff18731fda2/federatedIdentityCredential/9f4b1755-1391-4aff-894d-5ff1c88533cf"
}
