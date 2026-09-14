variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-ecommerce-devops"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "southindia"
}

variable "acr_name" {
  description = "Name of the Azure Container Registry (must be globally unique)"
  type        = string
  default     = "devopscommerce"
}

variable "cluster_name" {
  description = "Name of the Azure Kubernetes Service (AKS) cluster"
  type        = string
  default     = "aks-ecommerce-devops"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "ecom-aks"
}

variable "node_count" {
  description = "Number of worker nodes in the default node pool"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Azure Virtual Machine size for the AKS worker nodes"
  type        = string
  default     = "Standard_B2s_v2"
}

variable "service_cidr" {
  description = "Network range used by Kubernetes services (must not overlap with VNet/subnet)"
  type        = string
  default     = "10.1.0.0/16"
}

variable "dns_service_ip" {
  description = "IP address within service_cidr used by CoreDNS"
  type        = string
  default     = "10.1.0.10"
}

variable "log_retention_days" {
  description = "Retention period (days) for Log Analytics and Application Insights data"
  type        = number
  default     = 30
}

variable "alert_email" {
  description = "Email address that receives monitoring and budget alerts"
  type        = string
  default     = "tushargsoni17@gmail.com"
}

variable "latency_alert_threshold_ms" {
  description = "Average server response time (ms) that triggers the high-latency alert"
  type        = number
  default     = 1000
}

variable "cpu_alert_threshold_percent" {
  description = "AKS node CPU usage percentage that triggers the high-CPU alert"
  type        = number
  default     = 80
}

variable "monthly_budget_inr" {
  description = "Monthly budget for the resource group (INR)"
  type        = number
  default     = 4000
}

variable "budget_start_date" {
  description = "Start date for the budget period, first of the month"
  type        = string
  default     = "2026-09-01T00:00:00Z"
}

variable "key_vault_name" {
  description = "Name of the Azure Key Vault (must be globally unique)"
  type        = string
  default     = "kv-ecommerce-devops"
}

variable "jwt_secret" {
  description = "JWT signing secret, stored in Key Vault. Pass via TF_VAR_jwt_secret, don't hardcode it in tfvars."
  type        = string
  sensitive   = true
}
