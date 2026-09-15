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

output "key_vault_name" {
  description = "The name of the Key Vault holding application secrets"
  value       = azurerm_key_vault.main.name
}

output "tenant_id" {
  description = "Azure AD tenant ID, required by the AKS Secrets Store CSI driver"
  value       = data.azurerm_client_config.current.tenant_id
}

output "aks_secrets_provider_client_id" {
  description = "Client ID of the AKS-managed identity used to read Key Vault secrets"
  value       = azurerm_kubernetes_cluster.aks.key_vault_secrets_provider[0].secret_identity[0].client_id
}

output "app_insights_connection_string" {
  description = "Application Insights connection string for the server to report telemetry"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}
