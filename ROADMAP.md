# Capstone Roadmap: E-Commerce CI/CD on Azure

This is your step-by-step execution plan. Each phase lists **goal → tasks → deliverable → done-when**. Work top to bottom — later phases depend on earlier ones. Check off tasks as you go.

**Where you are right now (confirmed from repo state):**
- ✅ Forked MERN e-commerce app (`client/` + `server/`)
- ✅ `docker-compose.yml` with client, server, mongo services
- ✅ `client/Dockerfile` and `server/Dockerfile` exist
- ✅ `server/app.js` refactored out of `index.js` (testability improvement) + a `health.test.js` added
- ✅ `.github/workflows/ci-cd.yml` file created but **empty** — no pipeline logic yet
- ❌ No IaC, no ACR, no AKS, no Key Vault, no monitoring, no cost tracking

---

## Phase 0: Decide Your Toolchain (do this first)

The brief says "Azure DevOps **or** Jenkins" and "Terraform **or** ARM". Since your repo is on GitHub (not Azure Repos) and you already started a `.github/workflows` file, the path of least resistance is:

- **CI/CD:** GitHub Actions (functionally equivalent to Azure Pipelines/Jenkins for grading purposes, and it's already half-set-up in your repo)
- **IaC:** Terraform (more portable, more common in job interviews than ARM/Bicep)

> If your course explicitly requires Azure DevOps Pipelines or Jenkins specifically (not GitHub Actions), tell me and I'll adjust the plan — the phases stay the same, only the pipeline syntax changes.

**Task:** Confirm with your instructor/rubric whether GitHub Actions counts as "Azure DevOps or Jenkins" for grading. If it must literally be Azure Pipelines, note it now before you build the CI step.

---

## Phase 1: Orient Yourself (no deliverable, just clarity)

**Goal:** Have a rough mental model of the end-to-end flow before touching anything, without writing a formal doc yet — you don't have enough real detail (resource names, actual pipeline shape, actual cost) until you've built the thing. The formal design doc gets written in Phase 9, from what you actually built, not from guesses.

**Tasks:**
1. Sketch (on paper, in a scratch file, whatever — not a deliverable) the flow: `git push → CI (lint/test/build) → Docker image → ACR → CD → AKS staging → approval → AKS production`.
2. Decide the Git branching model you'll use: `master` (production), `develop` (integration), `feature/*` (work branches), PRs required into `develop` and `master`. This gets applied in Phase 2.
3. Note which Azure services you'll touch (ACR, AKS, Key Vault, Monitor, Cosmos DB) so you're not caught off guard by names/concepts later — you don't need to understand each deeply yet, just know they're coming.

**Done when:** You can describe the flow above out loud in under a minute. Nothing to commit here.

---

## Phase 2: Source Control & Git Workflow

**Goal:** Real branch discipline, not just a single `master` branch.

**Tasks:**
1. Create a `develop` branch from `master`.
2. Set branch protection rules on GitHub (Settings → Branches) for `master`: require PR review, require status checks to pass (once CI exists) before merge.
3. From now on, work in `feature/<short-name>` branches, PR into `develop`, then periodically PR `develop` → `master`.
4. Make sure `README.md` documents setup steps (yours already does — verify it's current after your `app.js`/test changes).

**Deliverable:** Branching strategy in place (documented properly in `docs/design.md` during Phase 9).

**Done when:** `master` is protected and you've merged at least one PR through the flow.

---

## Phase 3: CI Pipeline (fill in `.github/workflows/ci-cd.yml`)

**Goal:** Every push/PR automatically installs deps, lints, runs tests, and builds — no manual steps.

**Tasks:**
1. Build the CI job(s) in `.github/workflows/ci-cd.yml`:
   - Trigger on `push`/`pull_request` to `master` and `develop`
   - Job 1 — **server**: checkout → setup Node → `npm ci` in `server/` → `npm test` (your `jest` + `supertest` setup already supports this)
   - Job 2 — **client**: checkout → setup Node → `npm ci` in `client/` → build (`npm run build` or equivalent webpack script) → optionally lint
   - Cache `node_modules`/npm cache per job to speed up builds
2. Add a couple more real tests in `server/test/` beyond the health check (e.g., a route that doesn't need a live DB, or use `mongodb-memory-server` for a DB-backed test) — a single health test won't look convincing in review.
3. Make sure the workflow fails loudly on lint/test failure (don't swallow errors).

**Deliverable:** Working CI workflow visible in the GitHub Actions tab, green checkmarks on PRs.

**Done when:** Opening a PR against `develop` automatically runs and passes both jobs.

---

## Phase 4: Dockerization & Image Management

**Goal:** Both services build clean, minimal images and can run together locally; images get pushed to ACR.

**Tasks:**
1. Review/clean up `client/Dockerfile` and `server/Dockerfile` — use multi-stage builds (build stage with full deps, final stage copying only build output + prod deps) to keep images small.
2. Confirm `docker-compose.yml` still runs the full stack locally: `docker compose up --build`, verify client on `:8080`, server on `:3000`, mongo seeded.
3. Create an Azure Container Registry (ACR):
   ```
   az group create -n rg-ecommerce-capstone -l eastus
   az acr create -n <uniqueAcrName> -g rg-ecommerce-capstone --sku Basic
   ```
4. Add a CI/CD job that, on merge to `master`, builds both images tagged with the git SHA and pushes to ACR (`az acr build` or `docker build` + `docker push` after `az acr login`).

**Deliverable:** Images visible in ACR with tags; local `docker compose` still works.

**Done when:** You can pull and run the ACR-hosted images and they behave the same as local builds.

---

## Phase 5: IaC — Provision Azure Infrastructure with Terraform

**Goal:** All Azure resources are defined as code in `infra/`, not clicked together in the portal.

**Tasks:**
1. Create `infra/` folder with Terraform files: `main.tf`, `variables.tf`, `outputs.tf`.
2. Define resources:
   - Resource Group
   - VNet + subnets + NSGs
   - ACR (if not already created manually — prefer defining it here instead so it's reproducible)
   - AKS cluster (small node pool, e.g. 1-2 `Standard_B2s` nodes to control cost)
   - Azure Key Vault
3. Use a remote backend for Terraform state (Azure Storage Account + container) so state isn't just local.
4. `terraform init && terraform plan && terraform apply` — provision everything, verify in Azure Portal.

**Deliverable:** `infra/*.tf` files, applied and working AKS + ACR + VNet + Key Vault.

**Done when:** You can `terraform destroy` and `terraform apply` again and get an identical environment back.

---

## Phase 6: CD Pipeline — Deploy to AKS

**Goal:** Merges to `master` automatically deploy to AKS, with a manual gate before production.

**Tasks:**
1. Write Kubernetes manifests (`k8s/` folder): `Deployment` + `Service` for client, `Deployment` + `Service` for server, plus a `Secret`/`ConfigMap` for env vars (Mongo URI, JWT secret, etc. — sourced from Key Vault, see Phase 7).
2. Database: use **Azure Cosmos DB (Mongo API)** instead of the in-cluster Mongo container. Steps:
   - Provision Cosmos DB (Mongo API) via Terraform in `infra/` (Phase 5) — add the resource there, not clicked in the portal.
   - Update `MONGO_URI` to the Cosmos connection string (get it from the Cosmos resource, store it in Key Vault per Phase 7 — never commit it).
   - Test compatibility locally first: point `docker-compose.yml`'s server service at the Cosmos connection string (temporarily) and confirm `mongoose`/seed script still work — Cosmos's Mongo API has some behavioral differences (e.g., certain aggregation/index operators), so run your test suite and the app's core flows (seed, product listing, order creation) against it before relying on it in AKS.
   - Remove the `mongo` service from `docker-compose.yml` once confirmed (or keep it behind a profile for offline local dev, your call).
3. Extend the GitHub Actions workflow with a CD job:
   - `az aks get-credentials` to connect to the cluster
   - `kubectl apply -f k8s/` for a **staging** namespace automatically after CI passes
   - Add a manual approval gate (GitHub Environments with required reviewers) before applying to a **production** namespace
4. Verify: push to `master` → staging updates automatically → you approve → production updates.

**Deliverable:** Working staging → production deploy flow with an approval gate, app reachable via a LoadBalancer/Ingress IP.

**Done when:** A code change goes from `git push` to running on AKS without any manual `kubectl` commands (except the approval click).

---

## Phase 7: Security Integration

**Goal:** No secrets in code or YAML; least-privilege access; images scanned for vulnerabilities.

**Tasks:**
1. Move all secrets (Mongo URI, JWT secret, OAuth keys, Mailgun/Mailchimp keys, Azure Storage connection string) into Azure Key Vault.
2. Wire AKS to Key Vault using the **Secrets Store CSI Driver** (or Key Vault references in your CD pipeline that inject values as K8s secrets at deploy time — don't hardcode them in `k8s/*.yaml`).
3. Enable RBAC on AKS (`--enable-azure-rbac` or Kubernetes RBAC roles) — restrict who/what can modify deployments.
4. Add image vulnerability scanning: enable **Microsoft Defender for Containers** on ACR, or add `trivy` as a CI step that scans images before push and fails the build on critical CVEs.
5. Apply basic Pod Security Standards/Policies (restrict privileged containers, root users) in your K8s manifests.

**Deliverable:** No secret values committed anywhere in git history; Trivy/Defender scan results; RBAC config documented.

**Done when:** `git grep` across the repo turns up zero real secret values, and a CI run shows a vulnerability scan step executing.

---

## Phase 8: Monitoring & Cost Management

**Goal:** You can see what's happening in the cluster/app, get alerted on problems, and know what it costs.

**Tasks:**
1. Enable **Azure Monitor** (Container Insights) on the AKS cluster for node/pod metrics and logs.
2. Add **Application Insights** to the Node server (lightweight SDK integration) for request tracing/errors.
3. Build at least one dashboard (Azure Monitor workbook) showing pod health, request latency, error rate.
4. Set up at least one alert rule (e.g., pod restart count > N, or CPU > 80%) that notifies you (email/action group).
5. Go to **Azure Cost Management**, set a budget for the resource group, configure a budget alert (e.g., at 80% of budget).
6. Re-run the Azure Pricing Calculator with your *actual* deployed SKUs (AKS node size/count, ACR tier, Key Vault, Monitor/Log Analytics ingestion) and export the PDF — this replaces the rough Phase 1 estimate.

**Deliverable:** Screenshot(s) of dashboard + alert rule + cost budget + final Pricing Calculator export.

**Done when:** You've triggered (or simulated) an alert once and seen it fire.

---

## Phase 9: Documentation & Report

**Goal:** Assemble everything into the final submission package.

**Tasks:**
1. Write `docs/design.md` — the architecture/design doc, now written from what you actually built rather than guessed upfront:
   - CI/CD workflow architecture (the real one, as implemented)
   - Git branching strategy (as applied in Phase 2)
   - Containerization design (as built in Phase 4)
   - Architecture diagram (Client → Nginx → API → Cosmos DB, plus ACR, AKS, Key Vault, Monitor) — draw.io, Excalidraw, or the Mermaid diagram in the README extended with Azure services
2. Write `docs/report.md` (or convert to PDF) containing everything listed under "Student Submission Requirements" in `ecommerce_cicd_capstone_project.md`:
   - Overview, architecture diagram (reuse from `docs/design.md`), step-by-step setup instructions for each phase above
   - App feature summary, CI/CD stages, approval gates
   - Code snippets: Dockerfiles, pipeline YAML, Terraform, K8s manifests
   - Cost breakdown (from Phase 8's final Pricing Calculator export)
   - Security + performance summary
3. Update the main `README.md` if anything drifted from what you actually built.
4. Record the 15-20 min video walkthrough per the guidelines in `ecommerce_cicd_capstone_project.md` (Video Explanation Guidelines section) — do a live demo of a push triggering CI → CD → AKS deploy if possible, it's the strongest part of the demo.

**Deliverable:** `docs/design.md`, final report, cost PDF, GitHub repo link, video.

**Done when:** All 4 items under "Student Submission Requirements" are ready to submit.

---

## Suggested Order of Attack (summary)

1. Phase 0-1 — confirm toolchain, sketch the flow mentally (~30 min)
2. Phase 2 — branching setup (~30 min)
3. Phase 3 — CI pipeline working (this is your immediate next concrete task — the workflow file already exists and is empty)
4. Phase 4 — Docker cleanup + ACR
5. Phase 5 — Terraform infra
6. Phase 6 — CD to AKS
7. Phase 7 — security hardening
8. Phase 8 — monitoring + cost
9. Phase 9 — write design doc + report + video, from what you actually built

Each phase is independently demoable — you don't need to finish everything to show progress.
