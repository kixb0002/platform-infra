variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }

resource "azurerm_container_registry" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = "Basic"
  admin_enabled                 = false
  public_network_access_enabled = true
  tags                          = { project = "gitops", environment = "lab" }
  lifecycle { prevent_destroy = true }
}

output "id" { value = azurerm_container_registry.this.id }
output "login_server" { value = azurerm_container_registry.this.login_server }
