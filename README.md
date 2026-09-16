# MERN E-Commerce Cloud Infrastructure

[![Terraform](https://img.shields.io/badge/Terraform-1.3+-844FBA.svg?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-AKS-326CE5.svg?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Azure](https://img.shields.io/badge/Microsoft_Azure-Cloud_Infra-0078D4.svg?logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/)
[![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED.svg?logo=docker&logoColor=white)](https://www.docker.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Infrastructure code, Kubernetes manifests, and deployment pipelines for running a containerized MERN (MongoDB, Express, React, Node.js) application on Microsoft Azure.

The repository includes:
- Terraform configurations for provisioning an Azure Virtual Network, Azure Kubernetes Service (AKS), Azure Key Vault, and monitoring resources.
- Kubernetes manifests structured with Kustomize for staging and production environments.
- A GitHub Actions workflow that runs tests, builds container images, scans for vulnerabilities, and deploys to AKS.
- Docker configurations for the Express API and a multi-stage Nginx container for the React frontend.

---

## Table of contents

- [Architecture summary](#architecture-summary)
- [Repository structure](#repository-structure)
- [Infrastructure (Terraform)](#infrastructure-terraform)
  - [Provisioned resources](#provisioned-resources)
  - [Terraform quickstart](#terraform-quickstart)
  - [Input variables](#input-variables)
  - [Outputs](#outputs)
- [CI/CD pipeline (GitHub Actions)](#cicd-pipeline-github-actions)
  - [Pipeline stages](#pipeline-stages)
  - [Required secrets](#required-secrets)
- [Kubernetes configuration](#kubernetes-configuration)
  - [Base manifests](#base-manifests)
  - [Overlays](#overlays)
  - [Azure Key Vault CSI secrets](#azure-key-vault-csi-secrets)
  - [Manual deployment](#manual-deployment)
- [Containers and local development](#containers-and-local-development)
  - [Docker builds](#docker-builds)
  - [Local development with Docker Compose](#local-development-with-docker-compose)
- [Monitoring and security](#monitoring-and-security)
  - [Metrics and alerts](#metrics-and-alerts)
  - [Network security and access control](#network-security-and-access-control)
  - [Budget management](#budget-management)
- [Application workload](#application-workload)
- [License](#license)

---

## Architecture summary

| Component | Technology | Role |
| :--- | :--- | :--- |
| Cloud provider | Microsoft Azure | Infrastructure hosting (South India region) |
| Infrastructure as Code | Terraform (`>= 1.3.0`) | Provisions VNet, Subnets, NSG, AKS, Key Vault, and Log Analytics |
| Orchestration | Kubernetes (AKS) | Runs application workloads across 2 worker nodes |
| Config management | Kustomize | Manages base manifests and environment overlays |
| CI/CD | GitHub Actions | Runs unit tests, builds images, and coordinates deployments |
| Container registry | Azure Container Registry (ACR) | Stores versioned container images |
| Vulnerability scanner | Trivy | Scans container images for operating system and package CVEs |
| Secrets storage | Azure Key Vault + CSI Driver | Injects runtime secrets into pods via managed identity |
| Web server | Nginx Alpine | Serves React static files and handles SPA routing and rate limiting |
| Observability | Azure Monitor & App Insights | Collects container logs, API telemetry, and triggers metric alerts |
| FinOps | Azure Budgets | Tracks monthly spend against a $50 threshold |

---

## Repository structure

```text
mern-ecommerce/
├── .github/
│   └── workflows/
│       └── ci-cd.yml             # CI/CD pipeline (Test, Build, Scan, Deploy)
├── infra/                        # Terraform configurations
│   ├── main.tf                   # VNet, Subnet, AKS Cluster, ACR Role Assignment
│   ├── variables.tf              # Input variable definitions
│   ├── security.tf               # Azure Key Vault, Access Policies, NSG Rules
│   ├── monitoring.tf             # Log Analytics, App Insights, Metric Alerts
│   ├── cost-management.tf        # Azure Consumption Budget
│   └── outputs.tf                # Cluster connection commands and resource IDs
├── kubernetes/                   # Kubernetes manifests
│   ├── base/                     # Shared base configurations
│   │   ├── client.yaml           # Frontend Deployment & LoadBalancer Service (:80)
│   │   ├── server.yaml           # Backend Deployment & LoadBalancer Service (:3000)
│   │   ├── mongo.yaml            # MongoDB Deployment & Service (:27017)
│   │   ├── rbac.yaml             # ServiceAccount and Role definitions
│   │   ├── secret-provider.yaml  # Key Vault SecretProviderClass
│   │   └── kustomization.yaml    # Base resource list
│   └── overlays/                 # Environment overlays
│       ├── staging/              # Staging overlay (namespace: staging, 1 replica)
│       └── production/           # Production overlay (namespace: production, 2 replicas)
├── client/                       # Frontend application
│   ├── Dockerfile                # Multi-stage build (Node 18 -> Nginx Alpine)
│   ├── nginx.conf                # Nginx reverse proxy and rate limiting rules
│   └── package.json
├── server/                       # Backend REST API
│   ├── Dockerfile                # Node 18 Bullseye-slim image
│   ├── package.json
│   └── server.js
├── docker-compose.yml            # Local multi-container development environment
├── DevOpsCostReport.xlsx         # Cost analysis spreadsheet
└── README.md
```

---

## Infrastructure (Terraform)

Infrastructure files are in the [`infra/`](file:///d:/Projects/Capstone%20Projects/devOps/mern-ecommerce/infra) directory.

### Provisioned resources

1. Network: Virtual Network `vnet-ecommerce-aks` (`10.0.0.0/16`) in Azure region `southindia`, containing a dedicated subnet `subnet-aks` (`10.0.1.0/24`).
2. Network Security Group: `nsg-ecommerce-aks` attached to `subnet-aks`. Inbound rules allow port 80 (HTTP) and port 3000 (API), with an explicit rule denying other inbound internet traffic.
3. Azure Kubernetes Service (AKS): `aks-ecommerce-devops` cluster with 2 worker nodes (`Standard_B2s_v2`), Azure CNI networking, and an enabled Key Vault secrets provider add-on. An `AcrPull` role assignment allows the cluster to pull images directly from Azure Container Registry.
4. Azure Key Vault: `kv-ecommerce-devops` generates and stores a 48-character secret (`JWT-SECRET`). Access policies are granted to Terraform and the AKS secrets provider identity.
5. Observability: Log Analytics workspace `log-ecommerce-devops` (30-day retention) linked to Application Insights `appi-ecommerce-devops`. Includes two metric alerts: node CPU usage exceeding 80% for 5 minutes, and server pod restarting more than twice in 15 minutes.
6. Cost management: An Azure consumption budget of $50/month configured with email notifications at 80% and 100% of the threshold.

### Terraform quickstart

```bash
cd infra

# Initialize Terraform providers
terraform init

# Validate configuration syntax
terraform validate

# Create an execution plan
terraform plan -var="alert_email=devops-alerts@yourdomain.com" -out=tfplan

# Apply changes to Azure
terraform apply tfplan
```

To delete all provisioned resources:

```bash
terraform destroy -var="alert_email=devops-alerts@yourdomain.com"
```

### Input variables

| Variable | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `resource_group_name` | `string` | `"rg-ecommerce-devops"` | Azure Resource Group name |
| `location` | `string` | `"southindia"` | Target Azure region |
| `acr_name` | `string` | `"devopscommerce"` | Target Azure Container Registry name |
| `key_vault_name` | `string` | `"kv-ecommerce-devops"` | Azure Key Vault instance name |
| `alert_email` | `string` | *Required* | Email address receiving alerts and budget warnings |
| `monthly_budget_amount` | `number` | `50` | Monthly spending limit in subscription currency |
| `cluster_name` | `string` | `"aks-ecommerce-devops"`| Managed AKS cluster name |
| `node_count` | `number` | `2` | Number of worker nodes |
| `vm_size` | `string` | `"Standard_B2s_v2"` | Virtual machine SKU for worker nodes |
| `service_cidr` | `string` | `"10.1.0.0/16"` | CIDR range reserved for Kubernetes Services |
| `dns_service_ip` | `string` | `"10.1.0.10"` | CoreDNS IP address within the service CIDR |

### Outputs

Run `terraform output` to retrieve deployment values:
- `connect_command`: Azure CLI command to authenticate `kubectl` to the cluster (`az aks get-credentials ...`).
- `acr_login_server`: Login URL for Azure Container Registry.
- `key_vault_name`: Name of the provisioned Key Vault.
- `tenant_id`: Azure tenant ID.
- `aks_secrets_provider_client_id`: Client ID of the AKS managed identity used by the CSI driver.
- `app_insights_connection_string`: Connection string for application telemetry.

---

## CI/CD pipeline (GitHub Actions)

The workflow is defined in [`.github/workflows/ci-cd.yml`](file:///d:/Projects/Capstone%20Projects/devOps/mern-ecommerce/.github/workflows/ci-cd.yml).

### Pipeline stages

1. Tests and validation:
   - The `server` job sets up Node.js 18 with npm caching, installs dependencies with `npm ci`, and runs unit tests (`npm test`).
   - The `client` job sets up Node.js 18, installs dependencies, and runs Webpack production compilation (`npm run build`).
2. Image build and push:
   - Triggers on pushes to `develop` or `master` after both validation jobs succeed.
   - Builds `server` and `client` Docker images, tags them with the commit SHA and `latest`, and pushes both to Azure Container Registry.
3. Vulnerability scanning:
   - Runs Trivy on both pushed container images to inspect OS packages and application dependencies for vulnerabilities.
4. Deployment:
   - Pushes to `develop` deploy to the `staging` namespace.
   - Pushes to `master` deploy to the `production` namespace with 2 replicas per deployment.
   - Both deployment jobs set the Kubernetes context, configure the Key Vault SecretProviderClass, update image tags using Kustomize, apply manifests, and wait for rollout completion with `kubectl rollout status`.

### Required secrets

Set the following secrets in GitHub repository settings under Secrets and variables > Actions:

| Secret Name | Description |
| :--- | :--- |
| `ACR_NAME` | Azure Container Registry name (e.g. `devopscommerce`) |
| `ACR_USERNAME` | Registry username or Service Principal client ID |
| `ACR_PASSWORD` | Registry password or secret |
| `KUBE_CONFIG` | Complete kubeconfig file content for AKS access |
| `APP_INSIGHTS_CONNECTION_STRING` | Application Insights connection string |
| `KEY_VAULT_NAME` | Azure Key Vault name (`kv-ecommerce-devops`) |
| `AZURE_TENANT_ID` | Azure tenant ID |
| `AKS_SECRETS_PROVIDER_CLIENT_ID` | Managed identity client ID for the CSI driver |

---

## Kubernetes configuration

Manifests in [`kubernetes/`](file:///d:/Projects/Capstone%20Projects/devOps/mern-ecommerce/kubernetes) use Kustomize to separate shared definitions from environment-specific settings.

### Base manifests

- `client.yaml`: Nginx frontend deployment and a LoadBalancer service exposing port 80 (mapped to container port 8080).
- `server.yaml`: Express API deployment and a LoadBalancer service exposing port 3000. Configured with database connection strings and secret volume mounts.
- `mongo.yaml`: MongoDB deployment with an internal ClusterIP service on port 27017.
- `rbac.yaml`: ServiceAccount, Role, and RoleBinding definitions for cluster permissions.
- `secret-provider.yaml`: SecretProviderClass connecting pods to Azure Key Vault via the CSI driver.

### Overlays

- `staging`: Deploys into the `staging` namespace with 1 replica per service.
- `production`: Deploys into the `production` namespace and applies `replicas-patch.yaml` to scale frontend and backend pods to 2 replicas.

### Azure Key Vault CSI secrets

The backend uses the Secrets Store CSI driver to retrieve runtime values:
1. `secret-provider.yaml` configures the SecretProviderClass with the Key Vault name, tenant ID, and user-assigned managed identity.
2. The CSI driver reads `JWT-SECRET` from Key Vault and creates a Kubernetes secret named `server-secrets`.
3. The server pod mounts the volume and sources `JWT_SECRET` directly into its environment variables.

### Manual deployment

```bash
# Authenticate kubectl to AKS
az aks get-credentials --resource-group rg-ecommerce-devops --name aks-ecommerce-devops

# Deploy to staging
kubectl apply -k kubernetes/overlays/staging
kubectl rollout status deployment/server -n staging
kubectl rollout status deployment/client -n staging

# Deploy to production
kubectl apply -k kubernetes/overlays/production
kubectl rollout status deployment/server -n production
kubectl rollout status deployment/client -n production

# View running pods and services
kubectl get pods,svc -n production
```

---

## Containers and local development

### Docker builds

- Frontend ([`client/Dockerfile`](file:///d:/Projects/Capstone%20Projects/devOps/mern-ecommerce/client/Dockerfile)): Multi-stage build using `node:18-bullseye-slim` to compile Webpack assets, then copying the `dist/` directory into `nginx:alpine` (~25MB). The Nginx configuration handles SPA routing via `try_files` and enforces a rate limit of 10 requests per second per IP.
- Backend ([`server/Dockerfile`](file:///d:/Projects/Capstone%20Projects/devOps/mern-ecommerce/server/Dockerfile)): Single-stage container built from `node:18-bullseye-slim` running the Express application on port 3000.

### Local development with Docker Compose

To run the complete stack locally:

```bash
# Build and start services
docker-compose up --build

# Endpoints:
# Frontend: http://localhost:8080
# Backend:  http://localhost:3000

# Stop containers and remove network
docker-compose down
```

`docker-compose.yml` runs the client, API server, and MongoDB on a shared bridge network (`app-network`).

---

## Monitoring and security

### Metrics and alerts

- Centralized logs: AKS container logs stream to Log Analytics workspace `log-ecommerce-devops`.
- Telemetry: Express requests, dependencies, and exceptions report to Application Insights.
- Metric alert 1 (`alert-aks-cpu-high`): Fires when cluster node CPU utilization averages over 80% across a 5-minute window.
- Metric alert 2 (`alert-server-pod-restarts`): Fires when backend pods restart more than twice within 15 minutes.

### Network security and access control

- Network isolation: Subnet NSG denies all unsolicited inbound traffic except ports 80 and 3000. The MongoDB instance has no public IP and only accepts connections from within the cluster.
- Pod identity: Key Vault credentials are read through an Azure Managed Identity; no long-lived passwords are saved in manifests or repositories.
- Workload permissions: Server pods run with an explicit ServiceAccount (`server-sa`) rather than default permissions.

### Budget management

An Azure Consumption Budget monitors the resource group with a $50 monthly limit, sending alerts when actual spending reaches 80% ($40) and 100% ($50).

---

## Application workload

The platform hosts an e-commerce application with the following components:
- Frontend: Single-page application built with React, Redux, Bootstrap, and Webpack.
- Backend: REST API built with Node.js, Express, Passport authentication (JWT, OAuth), and Socket.io.
- Database: MongoDB with Mongoose schemas for products, users, carts, orders, and reviews.

---

## License

This project is distributed under the [MIT License](LICENSE).
