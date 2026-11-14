# Infrastructure existante

Des modules Terraform ACR/Key Vault sont maintenant disponibles dans
`modules/`, avec une composition LAB dans `environments/lab/`. AzureRM 5.13.0
est figé et la configuration passe `terraform validate`. L'apply autorisé a
créé l'ACR Basic et le rôle AcrPull ; le plan suivant ne détecte aucune dérive.
Key Vault est désactivé par défaut tant que le réseau privé
n'est pas validé. Lire `environments/lab/README.md` avant toute exécution.

Le cluster AKS existant est découvert via Azure CLI, sans création ni import Terraform.
Les futures ressources seront limitées à `RG-Taoufik-Mellah` et aux droits effectivement
vérifiés. Ne pas déclarer le cluster comme une nouvelle ressource Terraform.

Owner sur ce groupe ne donne pas de droits implicites sur le groupe managé AKS,
les ressources réseau partagées, le tenant Entra ou l'abonnement. L'enregistrement
des providers, les applications Entra et les zones DNS partagées peuvent nécessiter
une intervention administrateur distincte.

Publication : https://github.com/kixb0002/platform-infra, branche main.
Le workflow de validation Terraform a réussi sur le commit initial a01b514 :
https://github.com/kixb0002/platform-infra/actions/runs/43617732321.
La CI valide les fichiers sans effectuer de plan/apply Azure.
