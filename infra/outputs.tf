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
  value       = azurerm_container_registry.acr.login_server
}

output "connect_command" {
  description = "Command to configure kubectl to connect to the new cluster"
  value       = "az aks get-credentials --resource-group ${var.resource_group_name} --name ${azurerm_kubernetes_cluster.aks.name}"
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace backing Container Insights and Application Insights"
  value       = azurerm_log_analytics_workspace.main.id
}

output "application_insights_connection_string" {
  description = "Connection string for the server's Application Insights resource (set as APPLICATIONINSIGHTS_CONNECTION_STRING)"
  value       = azurerm_application_insights.server.connection_string
  sensitive   = true
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for the server's Application Insights resource"
  value       = azurerm_application_insights.server.instrumentation_key
  sensitive   = true
}

output "key_vault_uri" {
  description = "URI of the Key Vault holding app secrets"
  value       = azurerm_key_vault.main.vault_uri
}

output "aks_keyvault_identity_client_id" {
  description = "Client ID of the AKS-managed identity used by the Secrets Store CSI driver - set this as the AKS_KEYVAULT_IDENTITY_CLIENT_ID GitHub secret"
  value       = azurerm_kubernetes_cluster.aks.key_vault_secrets_provider[0].secret_identity[0].client_id
}
