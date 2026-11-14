# Rôle : Relie l’identité Entra importée au ServiceAccount Argo CD ; ne gère pas le nombre de nœuds AKS.
# Entra est géré par Terraform ; les objets Kubernetes SSO appartiennent à GitOps.
module "argocd_sso" {
  owner_object_ids = ["c5381316-b07f-40a2-a555-d89eee00b7dc"]
  source           = "../../modules/argocd-sso"
  oidc_issuer_url  = data.azurerm_kubernetes_cluster.existing.oidc_issuer_url
  redirect_uri     = "https://localhost:8080/auth/callback"
}

output "argocd_sso_client_id" { value = module.argocd_sso.client_id }
