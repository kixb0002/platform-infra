# Rôle : IP de l’expérience HTTPS ; désactivée à l’état interne, indépendante du Load Balancer sortant partagé AKS.
variable "enable_public_api" {
  type        = bool
  default     = false
  description = "Activer seulement après accord sur les frais réseau et l’exposition HTTPS de l’API de démonstration."
}

resource "azurerm_public_ip" "ecommerce_api" {
  count               = var.enable_public_api ? 1 : 0
  name                = "pip-ecommerce-api-lab"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "ecommerce-tm-${local.suffix}"
  tags = {
    environment = "lab"
    purpose     = "ecommerce-https"
  }
  # Protège une éventuelle prochaine IP ; retirer explicitement avant son futur nettoyage.
  lifecycle { prevent_destroy = true }
}

# Attribution limitée au scope ci-dessous ; ne pas élargir au groupe ou à la souscription.
resource "azurerm_role_assignment" "aks_public_ip" {
  count                = var.enable_public_api ? 1 : 0
  scope                = azurerm_public_ip.ecommerce_api[0].id
  role_definition_name = "Network Contributor"
  principal_id         = data.azurerm_kubernetes_cluster.existing.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

output "public_api_fqdn" {
  value = try(azurerm_public_ip.ecommerce_api[0].fqdn, null)
}
