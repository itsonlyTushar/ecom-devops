data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "azurerm_consumption_budget_resource_group" "monthly" {
  name              = "budget-ecommerce-monthly"
  resource_group_id = data.azurerm_resource_group.main.id

  amount     = var.monthly_budget_inr
  time_grain = "Monthly"

  time_period {
    start_date = var.budget_start_date
  }

  notification {
    enabled        = true
    threshold      = 80.0
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = [var.alert_email]
  }

  notification {
    enabled        = true
    threshold      = 100.0
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = [var.alert_email]
  }

  notification {
    enabled        = true
    threshold      = 100.0
    operator       = "GreaterThan"
    threshold_type = "Forecasted"
    contact_emails = [var.alert_email]
  }
}
