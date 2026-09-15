data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-ecommerce-devops"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = "DevOps-Capstone"
    Project     = "MERN-Ecommerce"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_application_insights" "main" {
  name                = "appi-ecommerce-devops"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "Node.JS"

  tags = {
    Environment = "DevOps-Capstone"
    Project     = "MERN-Ecommerce"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_monitor_action_group" "main" {
  name                = "ag-ecommerce-alerts"
  resource_group_name = var.resource_group_name
  short_name          = "ecomalerts"

  email_receiver {
    name          = "primary-oncall"
    email_address = var.alert_email
  }
}

resource "azurerm_monitor_metric_alert" "aks_cpu_high" {
  name                = "alert-aks-cpu-high"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_kubernetes_cluster.aks.id]
  description         = "AKS node CPU usage has exceeded 80% for 5 minutes"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_cpu_usage_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

resource "azurerm_monitor_metric_alert" "server_pod_restarts" {
  name                = "alert-server-pod-restarts"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_kubernetes_cluster.aks.id]
  description         = "Server pod has restarted more than twice in 15 minutes"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "kube_pod_status_ready"
    aggregation      = "Total"
    operator         = "LessThan"
    threshold        = 1
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
