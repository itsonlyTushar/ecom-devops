resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${var.cluster_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
}

resource "azurerm_application_insights" "server" {
  name                = "appi-ecommerce-server"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "Node.JS"
}

resource "azurerm_monitor_action_group" "ops" {
  name                = "ag-ecommerce-ops"
  resource_group_name = var.resource_group_name
  short_name          = "ecom-ops"

  email_receiver {
    name                    = "ops-email"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_metric_alert" "server_response_time" {
  name                = "alert-server-high-latency"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.server.id]
  description         = "Server average response time is too high"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "requests/duration"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.latency_alert_threshold_ms
  }

  action {
    action_group_id = azurerm_monitor_action_group.ops.id
  }
}

resource "azurerm_monitor_metric_alert" "aks_node_cpu" {
  name                = "alert-aks-node-cpu-high"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_kubernetes_cluster.aks.id]
  description         = "AKS node CPU is too high"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_cpu_usage_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_alert_threshold_percent
  }

  action {
    action_group_id = azurerm_monitor_action_group.ops.id
  }
}
