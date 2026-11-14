# Identités SSO Argo CD

Ce module adopte l'application Entra existante, son service principal,
son URL Web de retour et sa fédération AKS. Il ne gère aucun objet Kubernetes,
aucun secret client et aucun rôle Azure. AzureAD est figé à 3.10.0.

Les quatre ressources Terraform décrivent trois objets Entra ; la liste des
redirect URIs est un sous-ensemble distinct de l'application, géré par la
ressource granulaire `azuread_application_redirect_uris`. Il n'y a pas de
double gestion du champ redirect URIs par l'application registration.

Les imports LAB sont déclarés dans `environments/lab/sso-imports.tf`. Ils
restent présents comme trace d'adoption et sont sans effet supplémentaire
après l'import initial. Le service principal requiert ici le format qualifié
`/servicePrincipals/<object-id>` avec AzureAD 3.10.0.

Tous les objets sont protégés par `prevent_destroy`. Le champ historique
`api.requestedAccessTokenVersion`, initialement null, est volontairement ignoré
sur l'application : ce provider le lit comme 0 alors que sa configuration
accepte 1 ou 2 et propose 2 par défaut. Le conserver évite une modification
étrangère à l'import. L'issuer OIDC du SSO reste explicitement v2.0.
Les autres réglages déclarés restent contrôlés par Terraform.

L'activation Workload Identity de l'AKS reste un prérequis existant : AKS est
encore une data source, sans import complet du cluster dans cette étape.
L'identité utilisateur administrateur et les paramètres Kubernetes SSO sont
définis dans l'overlay GitOps `bootstrap/argocd-lab`, pas dans ce module.
