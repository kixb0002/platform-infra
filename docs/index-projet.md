# Lire le projet dans le bon ordre

1. **Reprendre le LAB** : [guide et schéma](reprendre-le-lab.md).
2. **Comprendre l’API** : ecommerce-app/app.py, tests/test_api.py et Dockerfile.
3. **Comprendre la livraison** : workflow CI applicatif puis l’overlay Dev GitOps.
4. **Comprendre le cluster** : base Deployment/Service, namespaces, quotas,
   NetworkPolicy et AppProjects. Les commentaires expliquent leurs frontières.
5. **Comprendre l’infrastructure** : main.tf, modules ACR/SSO puis ci.tf.
6. **Comprendre les opérations** : scripts render/preview/verify avant apply.
7. **HTTPS** : expérience facultative dans platform/public-api, pas un prérequis.

Les commentaires décrivent le rôle et les choix de sécurité ; les fichiers docs
séparent les validations historiques de l’état réel constaté après les opérations.
Les manifests vendor sont préservés pour contrôler leurs sommes SHA256.
