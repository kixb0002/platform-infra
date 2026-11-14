# Extension Terraform du LAB existant

AzureRM 5.13.0 et AzureAD 3.10.0, modules ACR, Key Vault et SSO Argo CD.
Les identités Entra SSO existantes sont importées (4 adresses, aucune mutation
cloud). Le module `modules/argocd-sso` décrit le périmètre et les protections ;
les blocs d’import sont dans `sso-imports.tf`. Les patches Kubernetes restent
dans le dépôt GitOps. Le groupe et AKS sont exclusivement
des `data` sources : ni création, ni import, ni changement de leur cycle de vie.
L'enregistrement automatique des providers est désactivé, adapté à Owner sur
le seul RG. Un provider non enregistré doit être traité par l'administrateur
de l'abonnement ; ne pas élargir le périmètre du script.

Le plan par défaut prévoit :

- un ACR Basic sans compte admin, nom déterministe `tmgitops` + suffixe de huit
  caractères calculé depuis l'abonnement et le RG ; endpoint public authentifié ;
- un rôle `AcrPull` au kubelet AKS, limité au seul registre créé.

**Apply exécuté après accord : 2 créations, 0 modification, 0 suppression.**
ACR `tmgitops237d8c7f`, compte admin désactivé, rôle AcrPull au kubelet.
Le plan suivant ne détecte aucune dérive. L'ACR entraîne des frais récurrents. Aucun rôle de push
n'est accordé à une CI tant que son dépôt et son sujet OIDC ne sont pas connus.
Pour une cible privée, ACR Premium et Private Endpoint nécessitent un autre plan.

Le module Key Vault Standard est désactivé par défaut. Si activé, il impose RBAC,
purge protection, rétention 90 jours et accès public désactivé. Aucun secret ni
accès data-plane n'est créé. Sans Private Endpoint et DNS validés, le coffre ne
sera pas utilisable depuis AKS. Le VNet AKS est dans le groupe managé distinct :
les droits sur subnet, Private Endpoint et liaison DNS ne doivent pas être
supposés. Il faut d'abord valider les permissions/délégations nécessaires.

```bash
cd platform-infra/environments/lab
terraform init -input=false
terraform validate
export TF_VAR_subscription_id="$(az account show --query id -o tsv)"
terraform plan -out=/tmp/gitops-lab.tfplan
terraform show /tmp/gitops-lab.tfplan
```

Après accord explicite sur ce plan et ses coûts uniquement :

```bash
terraform apply /tmp/gitops-lab.tfplan
```

Le state local de cette session est conservé sous
`/home/user/.local/state/taoufik-gitops/lab/terraform.tfstate`, dans un répertoire
Linux privé persistant, hors du montage Windows. Utiliser depuis la racine
du workspace `bash scripts/terraform-lab.sh init`, puis `plan` ou `validate`.
Le script configure le backend local avec le chemin de l'utilisateur courant.
Les commandes directes ci-dessus nécessitent un backend déjà initialisé ainsi.
Les plans/state peuvent contenir les
attributs sensibles lus depuis AKS : conserver sur stockage Linux privé, jamais
dans Git ou un artifact CI public. Avant toute collaboration ou automatisation,
mettre en place un backend Blob avec verrouillage et accès Entra validés. Aucun
backend distant n'est inventé ni créé implicitement.

Validation après création : ACR sans admin, rôle kubelet au scope exact, pull
d'une image réelle validé depuis Dev. Rollback : `prevent_destroy` protège les
ressources persistantes ; corriger en avant, sans lancer `terraform destroy`.
Ne jamais désactiver purge protection pour simplifier un nettoyage.

Sources :
- https://registry.terraform.io/providers/hashicorp/azurerm/5.13.0/docs/resources/container_registry
- https://registry.terraform.io/providers/hashicorp/azurerm/5.13.0/docs/resources/key_vault
