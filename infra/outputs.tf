output "resource_group_name" {
  description = "The Resource Group containing all resources"
  value       = var.resource_group_name
}

output "kubernetes_cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "acr_login_server" {
  description = "The login server for the Azure Container Registry"
  value       = data.azurerm_container_registry.acr.login_server
}

output "connect_command" {
  description = "Command to configure kubectl to connect to the new cluster"
  value       = "az aks get-credentials --resource-group ${var.resource_group_name} --name ${azurerm_kubernetes_cluster.aks.name}"
}
