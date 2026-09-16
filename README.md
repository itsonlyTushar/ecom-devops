# MERN E-Commerce DevOps & Cloud Infrastructure Platform

[![Terraform](https://img.shields.io/badge/Terraform-1.3+-844FBA.svg?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-AKS-326CE5.svg?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Azure](https://img.shields.io/badge/Microsoft_Azure-Cloud_Infra-0078D4.svg?logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI%2FCD-2088FF.svg?logo=githubactions&logoColor=white)](https://github.com/features/actions)
[![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED.svg?logo=docker&logoColor=white)](https://www.docker.com/)
[![Trivy](https://img.shields.io/badge/Security-Trivy_Scanning-1904DA.svg)](https://trivy.dev/)
[![Kustomize](https://img.shields.io/badge/GitOps-Kustomize-326CE5.svg)](https://kustomize.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

This repository contains the complete, production-grade **DevOps Engineering & Infrastructure as Code (IaC)** ecosystem for a containerized multi-tier MERN (MongoDB, Express, React, Node.js) e-commerce application.

The project is dedicated to modern cloud engineering practices: provisioning automated cloud infrastructure on **Microsoft Azure** using **Terraform**, orchestrating scalable workloads on **Azure Kubernetes Service (AKS)** with **Kustomize**, implementing continuous integration and continuous deployment (**CI/CD**) with **GitHub Actions**, enforcing container vulnerability scanning with **Trivy**, integrating zero-trust secrets management with **Azure Key Vault CSI Driver**, and managing observability and FinOps with **Azure Monitor**, **Application Insights**, and **Azure Budgets**.

---

## Table of Contents

- [DevOps Architecture](#devops-architecture)
- [DevOps Capabilities & Highlights](#devops-capabilities--highlights)
- [Repository Structure](#repository-structure)
- [Infrastructure as Code (Terraform)](#infrastructure-as-code-terraform)
  - [Provisioned Cloud Resources](#provisioned-cloud-resources)
  - [Terraform Quickstart](#terraform-quickstart)
  - [Input Variables Reference](#input-variables-reference)
  - [Terraform Outputs](#terraform-outputs)
- [CI/CD & DevSecOps Pipeline (GitHub Actions)](#cicd--devsecops-pipeline-github-actions)
  - [Pipeline Architecture & Lifecycle](#pipeline-architecture--lifecycle)
  - [Required Pipeline Secrets](#required-pipeline-secrets)
- [Kubernetes & GitOps Configuration (K8s / Kustomize)](#kubernetes--gitops-configuration-k8s--kustomize)
  - [Base Architecture](#base-architecture)
  - [Environment Overlays (Staging vs Production)](#environment-overlays-staging-vs-production)
  - [Azure Key Vault CSI Secrets Integration](#azure-key-vault-csi-secrets-integration)
  - [Manual Kubernetes Deployment](#manual-kubernetes-deployment)
- [Containerization & Local Dev Emulation](#containerization--local-dev-emulation)
  - [Multi-Stage Builds & Nginx Hardening](#multi-stage-builds--nginx-hardening)
  - [Local Testing with Docker Compose](#local-testing-with-docker-compose)
- [Observability, Security & FinOps](#observability-security--finops)
  - [Monitoring & Metric Alerting](#monitoring--metric-alerting)
  - [DevSecOps Hardening](#devsecops-hardening)
  - [FinOps & Budget Management](#finops--budget-management)
- [Target Application Workload Overview](#target-application-workload-overview)
- [License](#license)

---

## DevOps Capabilities & Highlights

| Domain | Implementation | Description |
| :--- | :--- | :--- |
| **Infrastructure as Code (IaC)** | **Terraform** (`>= 1.3.0`) | Declarative provisioning of Azure VNet, Subnets, NSG, AKS cluster, Key Vault, Log Analytics, Application Insights, and Cost Budgets. |
| **Container Orchestration** | **Kubernetes (AKS) + Kustomize** | Declarative manifest management with base configuration and environment overlays (`staging` and `production`) featuring dynamic replicas patching. |
| **Continuous Integration (CI)** | **GitHub Actions** | Automated parallel testing for Node.js API and Webpack frontend compilation on pull requests and pushes. |
| **Continuous Delivery (CD)** | **GitHub Actions + Kustomize** | Automatic branch-based deployment (`develop` $\rightarrow$ staging, `master` $\rightarrow$ production) with automated rollout health checks. |
| **Container Security & Scanning** | **Aquasecurity Trivy** | Shift-left container security scanning during CI/CD to detect `CRITICAL` and `HIGH` CVE vulnerabilities before deployment. |
| **Secrets Management** | **Azure Key Vault CSI Driver** | Zero-trust secrets injection; Kubernetes pods retrieve runtime secrets (`JWT-SECRET`) directly from Key Vault without storing them in Git. |
| **Network Security** | **Azure NSG + K8s RBAC** | Subnet-level network security group restricting traffic strictly to HTTP (`80`) and API (`3000`), paired with dedicated Kubernetes ServiceAccounts and Roles. |
| **Observability & Alerting** | **Azure Monitor & App Insights** | Automated telemetry for Node.js workloads, OMS log analytics integration, and metric alerts for pod restarts and node CPU thresholds ($>80\%$). |
| **Cloud FinOps** | **Azure Budgets & Cost Reporting** | Resource group spend capping with automated 80% and 100% threshold email notifications, accompanied by a comprehensive cost model (`DevOpsCostReport.xlsx`). |

---

## Repository Structure

```text
mern-ecommerce/
├── .github/
│   └── workflows/
│       └── ci-cd.yml             # Unified CI/CD pipeline (Test, Build, Trivy, Deploy)
├── infra/                        # Infrastructure as Code (Terraform)
│   ├── main.tf                   # VNet, Subnet, AKS Cluster, ACR Role Assignment
│   ├── variables.tf              # Input variable definitions & defaults
│   ├── security.tf               # Azure Key Vault, Access Policies, NSG Rules
│   ├── monitoring.tf             # Log Analytics, App Insights, Monitor Metric Alerts
│   ├── cost-management.tf        # Azure Consumption Budget & FinOps notifications
│   └── outputs.tf                # Connection strings, cluster IDs, client IDs
├── kubernetes/                   # Kubernetes Manifests & GitOps Configuration
│   ├── base/                     # Core reusable manifests
│   │   ├── client.yaml           # Frontend Deployment & LoadBalancer Service (Port 80)
│   │   ├── server.yaml           # Backend Deployment & LoadBalancer Service (Port 3000)
│   │   ├── mongo.yaml            # MongoDB Deployment & Service (Port 27017)
│   │   ├── rbac.yaml             # ServiceAccount, Role, and RoleBinding definitions
│   │   ├── secret-provider.yaml  # Azure Key Vault CSI SecretProviderClass specification
│   │   └── kustomization.yaml    # Base resource declaration
│   └── overlays/                 # Environment-specific overlays
│       ├── staging/              # Staging overlay (Namespace 'staging', 1 replica)
│       │   ├── kustomization.yaml
│       │   └── namespace.yaml
│       └── production/           # Production overlay (Namespace 'production', HA 2 replicas)
│           ├── kustomization.yaml
│           ├── namespace.yaml
│           └── replicas-patch.yaml
├── client/                       # Target Workload: Frontend Client
│   ├── Dockerfile                # Multi-stage production build (Node 18 -> Nginx Alpine)
│   ├── nginx.conf                # Production reverse proxy, rate limiting, SPA routing
│   └── package.json
├── server/                       # Target Workload: Backend REST API
│   ├── Dockerfile                # Lightweight Node 18 Bullseye production container
│   ├── package.json
│   └── server.js
├── docker-compose.yml            # Local DevOps development & integration testing
├── DevOpsCostReport.xlsx         # Cloud cost analysis & budget estimation report
└── README.md
```

---

## Infrastructure as Code (Terraform)

The cloud infrastructure is located in [`infra/`](file:///d:/Projects/Capstone%20Projects/devOps/mern-ecommerce/infra) and managed via **Terraform** (`>= 1.3.0`) targeting Microsoft Azure.

### Provisioned Cloud Resources

1. **Virtual Network & Subnets:**
   - VNet: `vnet-ecommerce-aks` (`10.0.0.0/16`) in Azure region `southindia`.
   - Dedicated AKS Subnet: `subnet-aks` (`10.0.1.0/24`).
2. **Network Security Group (NSG):**
   - NSG: `nsg-ecommerce-aks` bound to `subnet-aks`.
   - Security Rules:
     - `AllowHTTPInbound` (Priority 100): Port `80` from Internet.
     - `AllowServerAPIInbound` (Priority 110): Port `3000` from Internet.
     - `AllowAzureLoadBalancerInbound` (Priority 120): Internal Azure load balancer traffic.
     - `DenyAllOtherInbound` (Priority 4096): Explicit deny-all safeguard.
3. **Azure Kubernetes Service (AKS):**
   - Cluster: `aks-ecommerce-devops` with OIDC issuer enabled.
   - Node Pool: 2 worker nodes (`Standard_B2s_v2`).
   - Networking: Azure CNI plugin (`network_plugin = "azure"`), standard Load Balancer SKU.
   - OMS Agent: Directly integrated with Log Analytics for cluster-wide logging.
   - Key Vault CSI Driver: `key_vault_secrets_provider` with auto-rotation enabled.
   - RBAC / Identity: System-assigned managed identity with `AcrPull` role on Azure Container Registry (`devopscommerce`).
4. **Azure Key Vault:**
   - Vault: `kv-ecommerce-devops` standard SKU.
   - Automated secret generation: 48-character cryptographically secure `JWT-SECRET`.
   - Access Policies: Dedicated policies for Terraform administrator and AKS CSI driver identity.
5. **Observability & Metric Alerting:**
   - Log Analytics Workspace: `log-ecommerce-devops` with 30-day retention.
   - Application Insights: `appi-ecommerce-devops` configured for Node.js workloads.
   - Action Group: `ag-ecommerce-alerts` with on-call email notification routing.
   - Metric Alert 1: `alert-aks-cpu-high` triggers when node CPU usage exceeds 80% for 5 minutes.
   - Metric Alert 2: `alert-server-pod-restarts` triggers when server pods restart more than twice in 15 minutes.
6. **FinOps & Cost Management:**
   - Consumption Budget: `budget-ecommerce-devops` configured at resource group scope.
   - Alert notifications triggered automatically at 80% and 100% of the monthly threshold.

### Terraform Quickstart

```bash
cd infra

# Initialize Terraform providers and backend
terraform init

# Validate syntax and configuration integrity
terraform validate

# Generate and review execution plan
terraform plan -var="alert_email=devops-alerts@yourdomain.com" -out=tfplan

# Apply configuration to Azure
terraform apply tfplan
```

To destroy provisioned resources when no longer needed:
```bash
terraform destroy -var="alert_email=devops-alerts@yourdomain.com"
```

### Input Variables Reference

| Variable | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `resource_group_name` | `string` | `"rg-ecommerce-devops"` | Azure Resource Group name. |
| `location` | `string` | `"southindia"` | Azure target data center region. |
| `acr_name` | `string` | `"devopscommerce"` | Target Azure Container Registry name. |
| `key_vault_name` | `string` | `"kv-ecommerce-devops"` | Azure Key Vault instance name. |
| `alert_email` | `string` | *Required* | Email address receiving alerts and budget warnings. |
| `monthly_budget_amount` | `number` | `50` | Monthly spending limit in subscription currency. |
| `cluster_name` | `string` | `"aks-ecommerce-devops"`| Managed AKS cluster name. |
| `node_count` | `number` | `2` | Number of worker nodes in default pool. |
| `vm_size` | `string` | `"Standard_B2s_v2"` | Virtual machine SKU for cluster worker nodes. |
| `service_cidr` | `string` | `"10.1.0.0/16"` | CIDR range reserved for Kubernetes Services. |
| `dns_service_ip` | `string` | `"10.1.0.10"` | CoreDNS IP address within the service CIDR. |

### Terraform Outputs

Run `terraform output` to retrieve deployment metadata:
- `connect_command`: Ready-to-run Azure CLI command to authenticate `kubectl` to the AKS cluster (`az aks get-credentials ...`).
- `acr_login_server`: FQDN login URL for Azure Container Registry.
- `key_vault_name`: Provisioned Azure Key Vault name.
- `tenant_id`: Azure Active Directory tenant ID.
- `aks_secrets_provider_client_id`: Client ID of the AKS managed identity used by the CSI secrets store driver.
- `app_insights_connection_string`: Connection string for backend application telemetry.

---

## CI/CD & DevSecOps Pipeline (GitHub Actions)

The repository uses a fully automated GitHub Actions pipeline defined in [`.github/workflows/ci-cd.yml`](file:///d:/Projects/Capstone%20Projects/devOps/mern-ecommerce/.github/workflows/ci-cd.yml).

### Pipeline Architecture & Lifecycle

The pipeline executes across 4 sequential and parallel stages:

1. **Continuous Integration (Parallel Jobs):**
   - **`server` job:** Runs on Ubuntu Latest, checks out code, configures Node.js 18 with npm cache, installs dependencies via `npm ci`, and executes backend test suites via `npm test`.
   - **`client` job:** Runs in parallel on Node.js 18, installs dependencies via `npm ci`, and compiles the Webpack production bundle (`npm run build`).
2. **Container Build & Push (`acr-push`):**
   - Triggers automatically upon successful push to `develop` or `master`.
   - Uses `docker/setup-buildx-action` and authenticates to Azure Container Registry (`ACR_NAME.azurecr.io`).
   - Builds both `server` and `client` container images using their respective Dockerfiles.
   - Tags each image with both `latest` and the immutable Git commit SHA (`${{ github.sha }}`).
3. **Shift-Left DevSecOps Scanning (Trivy):**
   - Integrates `aquasecurity/trivy-action` directly after image compilation.
   - Scans both `server` and `client` container images for OS and library dependencies.
   - Flags and reports any vulnerabilities at `CRITICAL` or `HIGH` severity levels.
4. **Continuous Deployment (GitOps with Kustomize):**
   - **Staging Deployment (`deploy-staging`):** Triggers on push to `develop`.
     - Targets the `staging` environment.
     - Authenticates to AKS using `KUBE_CONFIG`.
     - Creates namespace `staging` if not present.
     - Creates Kubernetes secret `appinsights-secrets` with Application Insights telemetry keys.
     - Performs dynamic variable substitution on `kubernetes/base/secret-provider.yaml`.
     - Executes `kustomize edit set image` to inject the unique image tag `${{ github.sha }}`.
     - Deploys via `kubectl apply -k kubernetes/overlays/staging`.
     - Verifies rollout health with `kubectl rollout status` (180s timeout).
   - **Production Deployment (`deploy-production`):** Triggers on push to `master`.
     - Targets the `production` environment.
     - Executes identical validation and deployment steps against `kubernetes/overlays/production`.
     - Automatically provisions 2 replicas per pod for high availability via Kustomize patches.

### Required Pipeline Secrets

Configure the following secrets in **GitHub Repository Settings > Secrets and variables > Actions**:

| Secret Name | Description |
| :--- | :--- |
| `ACR_NAME` | Name of the Azure Container Registry (e.g., `devopscommerce`). |
| `ACR_USERNAME` | Admin / Service Principal username for ACR authentication. |
| `ACR_PASSWORD` | Access key / password for ACR authentication. |
| `KUBE_CONFIG` | Base64-encoded or raw `kubeconfig` file for AKS cluster access. |
| `APP_INSIGHTS_CONNECTION_STRING` | Instrumentation connection string from Application Insights. |
| `KEY_VAULT_NAME` | Name of the Azure Key Vault (`kv-ecommerce-devops`). |
| `AZURE_TENANT_ID` | Azure Active Directory Tenant ID. |
| `AKS_SECRETS_PROVIDER_CLIENT_ID` | Client ID of the AKS Key Vault CSI managed identity. |

---

## Kubernetes & GitOps Configuration (K8s / Kustomize)

All Kubernetes definitions reside in [`kubernetes/`](file:///d:/Projects/Capstone%20Projects/devOps/mern-ecommerce/kubernetes) and are organized using the **Kustomize** pattern.

### Base Architecture

- **`client.yaml`:**
  - Deployment managing Nginx-served frontend pods.
  - Service type `LoadBalancer` mapping incoming port `80` to container port `8080`.
- **`server.yaml`:**
  - Deployment managing Node.js API pods.
  - Service type `LoadBalancer` exposing port `3000`.
  - Environment variables configured for MongoDB (`mongodb://mongo:27017/mern_ecommerce`) and base routing.
  - Secrets injection: mounts CSI Secrets Store volume at `/mnt/secrets-store` and sources `JWT_SECRET` and `APPLICATIONINSIGHTS_CONNECTION_STRING` directly into pod environment variables.
- **`mongo.yaml`:**
  - Deployment running MongoDB container with internal ClusterIP Service on port `27017`.
- **`rbac.yaml`:**
  - Enforces least-privilege access by creating a dedicated `ServiceAccount` (`server-sa`), a `Role` with scoped permissions (read-only for ConfigMaps), and a binding (`server-rolebinding`).

### Environment Overlays (Staging vs Production)

```text
kubernetes/overlays/
├── staging/
│   ├── kustomization.yaml   # Sets namespace: staging, labels environment=staging
│   └── namespace.yaml       # Namespace definition for staging
└── production/
    ├── kustomization.yaml   # Sets namespace: production, applies replicas-patch.yaml
    ├── namespace.yaml       # Namespace definition for production
    └── replicas-patch.yaml  # Scales client & server deployments to 2 replicas
```

- **Staging:** Provides an isolated pre-production sandbox with 1 replica per service to minimize resource consumption.
- **Production:** Enforces high-availability (HA) requirements by applying `replicas-patch.yaml` to scale both frontend and backend workloads to 2 replicas.

### Azure Key Vault CSI Secrets Integration

Secrets management adheres to a zero-trust model using the **Secrets Store CSI Driver**:
1. The `SecretProviderClass` defined in [`kubernetes/base/secret-provider.yaml`](file:///d:/Projects/Capstone%20Projects/devOps/mern-ecommerce/kubernetes/base/secret-provider.yaml) communicates with Azure Key Vault using the AKS Managed Identity.
2. The CSI driver fetches `JWT-SECRET` from Key Vault and creates a native Kubernetes Secret (`server-secrets`).
3. The server deployment mounts the volume and binds the secret directly to environment variables without ever writing secrets to disk or source control.

### Manual Kubernetes Deployment

To deploy manifests manually using `kubectl` and `kustomize`:

```bash
# Connect to your AKS cluster
az aks get-credentials --resource-group rg-ecommerce-devops --name aks-ecommerce-devops

# Deploy Staging Environment
kubectl apply -k kubernetes/overlays/staging

# Check Staging Rollout Status
kubectl rollout status deployment/server -n staging
kubectl rollout status deployment/client -n staging

# Deploy Production Environment
kubectl apply -k kubernetes/overlays/production

# Check Production Rollout Status
kubectl rollout status deployment/server -n production
kubectl rollout status deployment/client -n production

# Inspect running pods and services
kubectl get pods,svc -n production
```

---

## Containerization & Local Dev Emulation

### Multi-Stage Builds & Nginx Hardening

#### Frontend Container (`client/Dockerfile`)
The frontend leverages a two-stage build to ensure the smallest possible attack surface and minimal image size:
1. **Build Stage (`node:18-bullseye-slim`):** Installs dependencies with `npm ci` and builds the optimized Webpack bundle into `/usr/src/app/dist`.
2. **Runtime Stage (`nginx:alpine`):** Copies solely the compiled static assets into `/usr/share/nginx/html` and discards all Node.js runtimes and `node_modules`.
3. **Nginx Security & Rate Limiting (`client/nginx.conf`):**
   - Configures request rate limiting using `limit_req_zone $binary_remote_addr zone=mylimit:10m rate=10r/s;` with a burst buffer of 70 requests.
   - Provides SPA route resolution via `try_files $uri /index.html;` to eliminate 404s on browser reloads.

#### Backend Container (`server/Dockerfile`)
The API container is built using `node:18-bullseye-slim`, leveraging clean caching, scoped dependency installations, and exposing port `3000`.

### Local Testing with Docker Compose

For local integration testing of the container topology before pushing to cloud infrastructure:

```bash
# Build and start all services (Client, API Server, MongoDB)
docker-compose up --build

# Verify running services
# Storefront UI:    http://localhost:8080
# REST API Health:  http://localhost:3000/api/health

# Stop and clean up containers and networks
docker-compose down
```

The `docker-compose.yml` runs all three containers on an isolated bridge network (`app-network`) and automatically seeds mock database records for initial testing.

---

## Observability, Security & FinOps

### Monitoring & Metric Alerting
- **Log Analytics:** Aggregates container stdout/stderr logs across all AKS pods for auditing and centralized log querying.
- **Application Insights:** Ingests live telemetry, HTTP request timings, and error rates from the Node.js API.
- **Azure Monitor Alerts:**
  - `alert-aks-cpu-high`: Triggers P2 alert if cluster node CPU utilization averages $>80\%$ over 5 minutes.
  - `alert-server-pod-restarts`: Triggers P1 critical alert if the API server experiences failure loops or crash restarts.

### DevSecOps Hardening
- **Vulnerability Management:** Trivy automated image scanning catches vulnerabilities before containers are deployed.
- **Zero-Trust Secrets:** No secrets stored in Git; secrets are generated via Terraform, vaulted in Azure Key Vault, and synced to pods on demand.
- **Firewall & Network Isolation:** NSG blocks all non-essential ingress traffic. Internal database (`mongo`) has no public IP address and is accessible only within the cluster network.
- **Kubernetes RBAC:** Pods execute using restricted `ServiceAccount` permissions rather than default cluster-admin privileges.

### FinOps & Budget Management
- **Budget Tracking:** Azure Consumption Budget enforces a \$50/month boundary on the resource group, sending automatic alerts at 80% (\$40) and 100% (\$50) spend marks.
- **Cost Optimization Modeling:** Comprehensive architecture cost estimation and resource tier sizing is detailed in [`DevOpsCostReport.xlsx`](file:///d:/Projects/Capstone%20Projects/devOps/mern-ecommerce/DevOpsCostReport.xlsx).

---

## Target Application Workload Overview

While this project is focused on the DevOps and Cloud Infrastructure platform, the underlying workload running within this infrastructure is a full-featured MERN stack e-commerce system:

- **Frontend:** React SPA with Redux state management, responsive UI, dynamic search, product filtering, and shopping cart workflows.
- **Backend:** Node.js & Express REST API featuring JWT authentication, role-based access control (Admin, Merchant, Member), Socket.io real-time chat, and third-party integrations (Mailgun, Mailchimp, Azure Blob Storage).
- **Database:** MongoDB with Mongoose ODM handling user identities, product catalog items, order state machines, and merchant records.
- **Health Probes:** Exposes `/health` and `/api/health` endpoints consumed by Kubernetes Liveness/Readiness probes and Azure monitoring agents.

---

## License

This project is licensed under the [MIT License](LICENSE).
