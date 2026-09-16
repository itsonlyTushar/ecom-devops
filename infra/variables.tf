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
  description = "Name of the Azure Container Registry"
  type        = string
  default     = "devopscommerce"
}

variable "key_vault_name" {
  description = "Name of the Azure Key Vault (must be globally unique, 3-24 alphanumeric/hyphen chars)"
  type        = string
  default     = "kv-ecommerce-devops"
}

variable "alert_email" {
  description = "Email address that receives Azure Monitor and budget alerts"
  type        = string
}

variable "monthly_budget_amount" {
  description = "Monthly spend budget for the resource group, in the subscription's billing currency"
  type        = number
  default     = 50
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
