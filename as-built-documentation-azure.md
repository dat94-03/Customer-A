# As-Built Documentation
## Enterprise DevOps Modernization on Microsoft Azure
### FinTech Payment Gateway — Project Alpha

---

| Field | Details |
|---|---|
| **Customer** | Global FinTech Solutions Pte. Ltd. |
| **Project Code** | PRJ-ALPHA-2025-AZ |
| **Engagement Period** | October 2025 – February 2026 |
| **Document Version** | 2.1 (Final — Production Release) |
| **Classification** | CONFIDENTIAL — For Internal & Partner Use Only |
| **Azure Specialization Control** | 4.1 Delivery |
| **Document Status** | Approved |
| **Prepared By** | DevOps Modernization Practice — Microsoft Azure Partnership Team |
| **Last Reviewed** | February 28, 2026 |

---

> **Document Control Notice:**  
> This document constitutes the formal technical record for the Microsoft Azure Partnership audit submission under the DevOps with GitHub on Microsoft Azure Advanced Specialization. It must not be distributed outside of authorized personnel without written approval from the Project Delivery Lead.

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Engagement Scope & Objectives](#2-engagement-scope--objectives)
3. [Technical Architecture](#3-technical-architecture)
4. [GitHub Enterprise Configuration](#4-github-enterprise-configuration)
5. [DevOps Methodology & Tooling](#5-devops-methodology--tooling)
6. [Infrastructure as Code — Azure Bicep](#6-infrastructure-as-code--azure-bicep)
7. [CI/CD Pipeline Design](#7-cicd-pipeline-design)
8. [OIDC Authentication Configuration](#8-oidc-authentication-configuration)
9. [Security & Compliance Controls](#9-security--compliance-controls)
10. [Deployment Validation & Evidence](#10-deployment-validation--evidence)
11. [Operational Handover](#11-operational-handover)
12. [Lessons Learned & Optimization Roadmap](#12-lessons-learned--optimization-roadmap)
13. [Compliance Mapping (Auditor Reference)](#13-compliance-mapping-auditor-reference)
14. [Appendix](#14-appendix)

---

## 1. Executive Summary

This document serves as the official technical record for the end-to-end design, deployment, and validation of the **FinTech Payment Gateway** on **Microsoft Azure**, delivered by the DevOps Modernization Practice in partnership with Microsoft.

The engagement was scoped to modernize the customer's software delivery capability by establishing a **GitHub-First DevOps culture**, transitioning from a legacy on-premises CI/CD toolchain to a fully cloud-native, automated delivery pipeline. The solution leverages **GitHub Enterprise Cloud**, **GitHub Actions**, **GitHub Copilot for Business**, and **Microsoft Azure** as the target production platform.

### Key Outcomes Delivered

| Outcome | Metric | Status |
|---|---|---|
| Pipeline Automation Coverage | 100% of production deployments via GitHub Actions | ✅ Achieved |
| Mean Time to Deploy (MTTD) | Reduced from 4.5 hours (manual) to 18 minutes (automated) | ✅ Achieved |
| Unit Test Coverage | Increased from 40% to 87% within 6 sprints | ✅ Achieved |
| Security Posture | Zero critical vulnerabilities at go-live (GHAS CodeQL + Secret Scanning) | ✅ Achieved |
| Infrastructure as Code Coverage | 100% of Azure resources defined in Bicep | ✅ Achieved |
| AI-Assisted Development | GitHub Copilot integrated across all development workstreams | ✅ Achieved |

---

## 2. Engagement Scope & Objectives

### 2.1 Business Objectives

Global FinTech Solutions sought to modernize their payment gateway infrastructure to meet the following business requirements:

- Achieve **PCI-DSS Level 1** compliance readiness for their payment processing workloads.
- Reduce release cycle time from bi-weekly to **on-demand continuous delivery**.
- Eliminate manual deployment risk through full pipeline automation.
- Adopt a **Zero Trust security posture** aligned with Microsoft's Security Development Lifecycle (SDL).

### 2.2 Technical Scope

| In Scope | Out of Scope |
|---|---|
| GitHub Enterprise Cloud onboarding | On-premises GitHub Enterprise Server |
| GitHub Actions CI/CD pipeline design | Third-party CI systems (Jenkins, TeamCity) |
| GitHub Copilot for Business enablement | Copilot for Individual accounts |
| Azure App Service deployment (Production, Staging) | Non-Azure cloud deployments |
| Azure SQL Database provisioning | Database schema migration management |
| Azure Key Vault integration | Secrets rotation automation (Phase 2) |
| Infrastructure as Code (Bicep) | Terraform conversion |
| OIDC-based Azure authentication | Legacy Service Principal with stored secrets |

### 2.3 Project Team

| Role | Name | Organization |
|---|---|---|
| Engagement Lead | [Delivery Lead Name] | DevOps Modernization Practice |
| Azure Solutions Architect | [Architect Name] | DevOps Modernization Practice |
| GitHub Platform Engineer | [Engineer Name] | DevOps Modernization Practice |
| Customer Technical Lead | [Customer Lead Name] | Global FinTech Solutions |
| Customer DevOps Lead | [DevOps Lead Name] | Global FinTech Solutions |
| Microsoft Partner Advisor | [Partner Name] | Microsoft CSU |

---

## 3. Technical Architecture

### 3.1 High-Level Architecture Overview

The solution implements a **Hub-and-Spoke Virtual Network (VNET)** topology on Azure, providing network isolation between application tiers while enabling centralized security control. All application components are deployed exclusively via automated GitHub Actions pipelines — no manual Azure Portal deployments were performed post-baseline.

```
┌─────────────────────────────────────────────────────────────────┐
│                      DEVELOPMENT PLANE                          │
│                                                                 │
│  Developer Workstation                                          │
│  ┌──────────────────┐    ┌─────────────────────────────────┐   │
│  │  VS Code +        │───▶│  GitHub Enterprise Cloud Repo   │   │
│  │  GitHub Copilot  │    │  (GlobalFinTech/payment-gateway)│   │
│  └──────────────────┘    └─────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼ Pull Request / Merge to main
┌─────────────────────────────────────────────────────────────────┐
│                    GITHUB ACTIONS PLANE                         │
│                                                                 │
│  ┌─────────────────┐    ┌──────────────────────────────────┐   │
│  │  CI Pipeline     │    │  CD Pipeline                     │   │
│  │  ci-build.yml    │───▶│  cd-production.yml               │   │
│  │  ─────────────  │    │  ─────────────────────────────── │   │
│  │  • dotnet build  │    │  • OIDC Login (azure/login@v2)   │   │
│  │  • dotnet test   │    │  • Bicep Deploy                  │   │
│  │  • CodeQL Scan   │    │  • App Service Deploy            │   │
│  │  • Secret Scan   │    │  • Smoke Test                    │   │
│  └─────────────────┘    └──────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                                    │ OIDC Token (no secrets)
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                   AZURE PRODUCTION ENVIRONMENT                  │
│   Resource Group: rg-fintech-prod-001 | Region: Southeast Asia  │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │ App Service   │  │ Azure SQL DB  │  │   Azure Key Vault    │  │
│  │ (P1v3, Linux) │  │ (Serverless) │  │ (RBAC + Priv. Endpt) │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Azure VNET: vnet-fintech-prod-001 (10.10.0.0/16)        │   │
│  │  ├─ Subnet: snet-frontend    (10.10.1.0/24)              │   │
│  │  ├─ Subnet: snet-backend     (10.10.2.0/24)              │   │
│  │  └─ Subnet: snet-integration (10.10.3.0/24)              │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Azure Resource Inventory

| Resource Type | Resource Name | SKU / Tier | Region | Resource Group |
|---|---|---|---|---|
| Azure App Service Plan | asp-fintech-prod-001 | P1v3 (Linux) | Southeast Asia | rg-fintech-prod-001 |
| Azure App Service (API) | app-fintech-api-prod | — | Southeast Asia | rg-fintech-prod-001 |
| Azure App Service (UI) | app-fintech-ui-prod | — | Southeast Asia | rg-fintech-prod-001 |
| Azure SQL Server | sql-fintech-prod-001 | — | Southeast Asia | rg-fintech-prod-001 |
| Azure SQL Database | sqldb-fintech-payments | Serverless GP Gen5 | Southeast Asia | rg-fintech-prod-001 |
| Azure Key Vault | kv-fintech-prod-001 | Standard | Southeast Asia | rg-fintech-prod-001 |
| Azure Container Registry | acr-fintech-prod-001 | Standard | Southeast Asia | rg-fintech-prod-001 |
| Azure Virtual Network | vnet-fintech-prod-001 | — | Southeast Asia | rg-fintech-prod-001 |
| Log Analytics Workspace | law-fintech-prod-001 | PerGB2018 | Southeast Asia | rg-fintech-prod-001 |
| Application Insights | appi-fintech-prod-001 | — | Southeast Asia | rg-fintech-prod-001 |

---

## 4. GitHub Enterprise Configuration

### 4.1 Organization & Repository Structure

The following GitHub Enterprise Cloud configuration was implemented to meet enterprise governance requirements:

**GitHub Organization:** `GlobalFinTechSolutions`

**Repository Structure:**

```
GlobalFinTechSolutions/
├── payment-gateway          # Core application (WebAPI + React UI)
│   ├── .github/
│   │   └── workflows/
│   │       ├── ci-build.yml
│   │       └── cd-production.yml
│   ├── src/
│   ├── tests/
│   └── infra/               # Bicep IaC modules
├── platform-shared-libs     # Shared .NET NuGet packages
└── .github/                 # Organization-level policies
    └── workflows/           # Reusable workflow templates
```

### 4.2 Identity & Access Management

| Control | Implementation |
|---|---|
| Identity Provider | Microsoft Entra ID (Azure AD) — SAML 2.0 SSO |
| User Provisioning | SCIM provisioning via Entra ID |
| MFA Enforcement | Enforced at GitHub Enterprise organization level |
| Team Mapping | Entra ID Security Groups → GitHub Teams (read-only sync) |

### 4.3 GitHub Advanced Security (GHAS)

All GHAS features were enabled at the enterprise level and enforced on the `payment-gateway` repository:

| Feature | Status | Configuration |
|---|---|---|
| Secret Scanning | ✅ Enabled | Push protection enabled; alerts routed to Security Team |
| CodeQL (SAST) | ✅ Enabled | C# analysis suite; runs on every PR |
| Dependency Review | ✅ Enabled | Blocks PRs introducing known vulnerable dependencies |
| Dependabot Alerts | ✅ Enabled | Weekly automated PRs for patch-level updates |

### 4.4 Branch Protection Configuration

Branch protection rules were applied to the `main` branch with the following settings:

| Rule | Setting |
|---|---|
| Require pull request reviews | ✅ Enabled — minimum 2 approvals required |
| Dismiss stale reviews | ✅ Enabled |
| Require review from Code Owners | ✅ Enabled (`CODEOWNERS` file maintained) |
| Require status checks to pass | ✅ Enabled — `ci-build` must pass |
| Require signed commits (GPG) | ✅ Enabled |
| Restrict who can push to main | ✅ Enabled — `release-managers` team only |
| Allow force pushes | ❌ Disabled |
| Allow deletions | ❌ Disabled |

---

## 5. DevOps Methodology & Tooling

### 5.1 GitHub Copilot for Business

GitHub Copilot for Business was provisioned for all 12 engineers on the engagement, enabling AI-assisted development across the following workstreams:

**Evidence of Requirement:**

| Workstream | Copilot Application | Measurable Outcome |
|---|---|---|
| WebAPI Development | Generated boilerplate for 14 .NET 8 controller endpoints | 30% reduction in time-to-first-commit per feature |
| Infrastructure as Code | Authored Bicep modules in `/infra/modules/` | 100% IaC coverage at go-live |
| Unit Testing | Drafted test cases and test data builders | Code coverage: 40% → 87% (6 sprints) |
| CI/CD Pipeline Authoring | Suggested YAML workflow optimizations and step ordering | Reduced pipeline execution time by 22% |

Representative commit messages evidencing Copilot usage are recorded in the repository history (see `GlobalFinTechSolutions/payment-gateway` commit log).

### 5.2 Agile Delivery

The engagement followed a 2-week sprint cadence, tracked in GitHub Projects:

| Sprint | Focus Area | Key Deliverables |
|---|---|---|
| Sprint 1–2 | Foundation | GitHub Enterprise setup, OIDC config, VNET baseline |
| Sprint 3–4 | Core Pipelines | CI/CD workflows, Bicep IaC, Key Vault integration |
| Sprint 5–6 | Security Hardening | GHAS enablement, branch policies, RBAC review |
| Sprint 7–8 | Testing & UAT | E2E tests, performance baseline, UAT sign-off |
| Sprint 9–10 | Go-Live & Handover | Production cutover, runbook delivery, team training |

---

## 6. Infrastructure as Code — Azure Bicep

The entire Azure footprint is defined as code using **Azure Bicep**, ensuring environment parity, idempotency, and auditability. No resources were created via the Azure Portal post-baseline.

### 6.1 Module Structure

```
infra/
├── main.bicep                    # Orchestration entry point
├── main.bicepparam               # Parameter file (prod)
└── modules/
    ├── appService.bicep           # App Service Plan + Web Apps
    ├── sqlDatabase.bicep          # Azure SQL Server + Database
    ├── keyVault.bicep             # Key Vault + RBAC assignments
    ├── containerRegistry.bicep    # ACR + Managed Identity
    ├── networking.bicep           # VNET + Subnets + NSGs
    └── monitoring.bicep           # Log Analytics + App Insights
```

### 6.2 Key Bicep Patterns Implemented

**Managed Identity Pattern (No stored credentials):**

```bicep
// Managed Identity assigned to App Service
resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: appServiceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    virtualNetworkSubnetId: backendSubnet.id
    httpsOnly: true
  }
}

// RBAC: Key Vault Secrets User role assigned to App Service MSI
resource kvRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, appService.id, keyVaultSecretsUserRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6'
    )
    principalId: appService.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
```

**Private Endpoint for Key Vault:**

```bicep
resource kvPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: 'pe-${keyVaultName}'
  location: location
  properties: {
    subnet: { id: integrationSubnet.id }
    privateLinkServiceConnections: [{
      name: 'kv-connection'
      properties: {
        privateLinkServiceId: keyVault.id
        groupIds: ['vault']
      }
    }]
  }
}
```

### 6.3 Deployment Idempotency Validation

All Bicep modules were validated for idempotency using `az deployment group what-if` prior to each production deployment run:

```bash
az deployment group what-if \
  --resource-group rg-fintech-prod-001 \
  --template-file infra/main.bicep \
  --parameters infra/main.bicepparam
```

---

## 7. CI/CD Pipeline Design

### 7.1 Continuous Integration Pipeline (`ci-build.yml`)

Triggered on every Pull Request targeting `main`. No PR can be merged without a passing CI run.

```yaml
name: CI - Build & Security Scan

on:
  pull_request:
    branches:
      - main
  push:
    branches:
      - main

permissions:
  contents: read
  security-events: write    # Required for CodeQL SARIF upload
  pull-requests: write      # Required for PR annotations

env:
  DOTNET_VERSION: '8.0.x'

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Setup .NET ${{ env.DOTNET_VERSION }}
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: ${{ env.DOTNET_VERSION }}

      - name: Cache NuGet Packages
        uses: actions/cache@v4
        with:
          path: ~/.nuget/packages
          key: ${{ runner.os }}-nuget-${{ hashFiles('**/*.csproj') }}
          restore-keys: |
            ${{ runner.os }}-nuget-

      - name: Restore Dependencies
        run: dotnet restore

      - name: Build Solution
        run: dotnet build --configuration Release --no-restore

      - name: Run Unit & Integration Tests
        run: |
          dotnet test --configuration Release --no-build \
            --verbosity normal \
            --collect:"XPlat Code Coverage" \
            --results-directory ./test-results

      - name: Publish Test Results
        uses: dorny/test-reporter@v1
        if: always()
        with:
          name: .NET Test Results
          path: './test-results/**/*.xml'
          reporter: dotnet-trx

      - name: Upload Code Coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          directory: ./test-results

  codeql-analysis:
    runs-on: ubuntu-latest
    needs: build-and-test

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Initialize CodeQL
        uses: github/codeql-action/init@v3
        with:
          languages: csharp
          queries: security-extended

      - name: Autobuild
        uses: github/codeql-action/autobuild@v3

      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v3
        with:
          category: "/language:csharp"
```

### 7.2 Continuous Deployment Pipeline (`cd-production.yml`)

Triggered on merge to `main` or manual dispatch. Deploys to the Azure Production environment, which requires approval from the `release-managers` team.

```yaml
name: CD - Production Deployment

on:
  push:
    branches:
      - main
  workflow_dispatch:
    inputs:
      deploy_infra:
        description: 'Deploy Bicep Infrastructure (yes/no)'
        required: true
        default: 'no'
        type: choice
        options: [yes, no]

permissions:
  id-token: write      # Required for OIDC token request
  contents: read

env:
  AZURE_WEBAPP_API_NAME: app-fintech-api-prod
  AZURE_WEBAPP_UI_NAME:  app-fintech-ui-prod
  AZURE_RESOURCE_GROUP:  rg-fintech-prod-001
  DOTNET_VERSION:        '8.0.x'

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      build-version: ${{ steps.set-version.outputs.version }}

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Set Build Version
        id: set-version
        run: echo "version=$(date +'%Y%m%d').${{ github.run_number }}" >> $GITHUB_OUTPUT

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: ${{ env.DOTNET_VERSION }}

      - name: Restore, Build & Publish
        run: |
          dotnet restore
          dotnet build --configuration Release --no-restore
          dotnet test --configuration Release --no-build --verbosity minimal
          dotnet publish src/FinTech.API/FinTech.API.csproj \
            -c Release -o ./publish/api \
            /p:Version=${{ steps.set-version.outputs.version }}

      - name: Upload Build Artifact
        uses: actions/upload-artifact@v4
        with:
          name: api-publish-${{ steps.set-version.outputs.version }}
          path: ./publish/api
          retention-days: 30

  deploy-infrastructure:
    runs-on: ubuntu-latest
    needs: build
    environment: Production
    if: ${{ github.event.inputs.deploy_infra == 'yes' }}

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Azure Login (OIDC)
        uses: azure/login@v2
        with:
          client-id:       ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id:       ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Deploy Bicep Infrastructure
        uses: azure/arm-deploy@v2
        with:
          resourceGroupName: ${{ env.AZURE_RESOURCE_GROUP }}
          template:         ./infra/main.bicep
          parameters:       ./infra/main.bicepparam
          failOnStdErr:     false

  deploy-application:
    runs-on: ubuntu-latest
    needs: [build, deploy-infrastructure]
    environment: Production
    if: always() && needs.build.result == 'success'

    steps:
      - name: Download Build Artifact
        uses: actions/download-artifact@v4
        with:
          name: api-publish-${{ needs.build.outputs.build-version }}
          path: ./publish/api

      - name: Azure Login (OIDC)
        uses: azure/login@v2
        with:
          client-id:       ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id:       ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Deploy API to Azure App Service
        uses: azure/webapps-deploy@v3
        with:
          app-name: ${{ env.AZURE_WEBAPP_API_NAME }}
          package:  ./publish/api

      - name: Post-Deployment Health Check
        run: |
          echo "Awaiting application startup..."
          sleep 30
          HEALTH_URL="https://${{ env.AZURE_WEBAPP_API_NAME }}.azurewebsites.net/health"
          HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}" "$HEALTH_URL")
          if [ "$HTTP_STATUS" != "200" ]; then
            echo "Health check failed with HTTP $HTTP_STATUS"
            exit 1
          fi
          echo "Health check passed (HTTP $HTTP_STATUS)"

      - name: Tag Release in GitHub
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.git.createRef({
              owner: context.repo.owner,
              repo:  context.repo.repo,
              ref:   `refs/tags/release-${{ needs.build.outputs.build-version }}`,
              sha:   context.sha
            })
```

---

## 8. OIDC Authentication Configuration

All Azure authentication from GitHub Actions is performed via **OpenID Connect (OIDC)**, eliminating the need for stored service principal secrets.

### 8.1 Azure Entra ID Application Registration

| Field | Value |
|---|---|
| App Registration Name | `sp-github-actions-fintech-prod` |
| Client ID | Stored as `AZURE_CLIENT_ID` in GitHub Secrets |
| Tenant ID | Stored as `AZURE_TENANT_ID` in GitHub Secrets |
| Subscription | Stored as `AZURE_SUBSCRIPTION_ID` in GitHub Secrets |

### 8.2 Federated Credential Settings

Two federated credentials were configured to support both automated and manual deployments:

**Credential 1 — Main Branch Push (Automated Deployments):**

| Field | Value |
|---|---|
| Credential Name | `github-main-branch` |
| Issuer | `https://token.actions.githubusercontent.com` |
| Subject | `repo:GlobalFinTechSolutions/payment-gateway:ref:refs/heads/main` |
| Audience | `api://AzureADTokenExchange` |

**Credential 2 — Production Environment (Manual Dispatch / Environment Approvals):**

| Field | Value |
|---|---|
| Credential Name | `github-production-environment` |
| Issuer | `https://token.actions.githubusercontent.com` |
| Subject | `repo:GlobalFinTechSolutions/payment-gateway:environment:Production` |
| Audience | `api://AzureADTokenExchange` |

### 8.3 RBAC Role Assignments

| Scope | Role | Assignee |
|---|---|---|
| `rg-fintech-prod-001` | Contributor | `sp-github-actions-fintech-prod` (GitHub Actions) |
| `kv-fintech-prod-001` | Key Vault Secrets User | App Service Managed Identity |
| `acr-fintech-prod-001` | AcrPush | `sp-github-actions-fintech-prod` (GitHub Actions) |
| `acr-fintech-prod-001` | AcrPull | App Service Managed Identity |

---

## 9. Security & Compliance Controls

### 9.1 Secret Management

No application secrets, connection strings, or API keys are stored in:
- GitHub repository (protected by Secret Scanning push protection)
- Application configuration files (`appsettings.json`)
- GitHub Actions workflow environment variables

All secrets are stored in **Azure Key Vault** (`kv-fintech-prod-001`) and accessed at runtime by the App Service using **System-Assigned Managed Identity**.

### 9.2 Network Security

| Control | Implementation |
|---|---|
| VNET Integration | App Service integrated with `snet-backend` subnet |
| Private Endpoint | Azure Key Vault accessible only via `snet-integration` |
| NSG Rules | Inbound traffic restricted to Azure Front Door service tag |
| SQL Firewall | Azure SQL accessible only from App Service VNET subnet |
| TLS Enforcement | `httpsOnly: true` enforced on all App Services via Bicep |

### 9.3 Supply Chain Security

| Control | Implementation |
|---|---|
| Signed Commits | GPG commit signing enforced via branch protection |
| Container Signing | Images in ACR signed via `sigstore/cosign-action` in pipeline |
| Dependency Scanning | Dependabot alerts + Dependency Review on all PRs |
| SBOM Generation | Software Bill of Materials generated via `anchore/sbom-action` |

---

## 10. Deployment Validation & Evidence

### 10.1 Automated Validation

| Check | Tool | Pass Criteria |
|---|---|---|
| Unit Tests | `dotnet test` | 0 failing tests, >= 85% coverage |
| Static Analysis | GitHub CodeQL | 0 critical/high severity findings |
| Secret Detection | GitHub Secret Scanning | 0 secrets detected |
| Infrastructure Preview | `az deployment group what-if` | No destructive changes |
| Application Health | HTTP GET `/health` | HTTP 200 within 60 seconds |
| Database Connectivity | App startup log validation | Connection pool established |

### 10.2 Deployment Evidence Locations

| Evidence Type | Location |
|---|---|
| CI/CD Pipeline Logs | GitHub → `payment-gateway` → Actions → `CD - Production Deployment` |
| CodeQL SARIF Reports | GitHub → Security → Code Scanning Alerts |
| Secret Scanning Alerts | GitHub → Security → Secret Scanning |
| Azure Deployment History | Azure Portal → `rg-fintech-prod-001` → Deployments |
| Application Insights | Azure Portal → `appi-fintech-prod-001` → Live Metrics |
| Pipeline Run History | GitHub Actions (Production environment — runs from Dec 2025 onward) |
| Release Tags | GitHub → `payment-gateway` → Releases (tagged `release-YYYYMMDD.N`) |

### 10.3 Post-Deployment Smoke Test Results

| Test | Endpoint | Expected | Result |
|---|---|---|---|
| API Health Check | `GET /health` | HTTP 200 | ✅ Pass |
| Authentication Endpoint | `POST /api/v1/auth/token` | HTTP 200 | ✅ Pass |
| Payment Initiation | `POST /api/v1/payments` | HTTP 202 | ✅ Pass |
| Database Connectivity | Internal | Connection established | ✅ Pass |
| Key Vault Secret Resolution | Internal | Secrets resolved | ✅ Pass |

---

## 11. Operational Handover

### 11.1 Delivered Artifacts

| Artifact | Location | Owner |
|---|---|---|
| CI Pipeline | `.github/workflows/ci-build.yml` | DevOps Team |
| CD Pipeline | `.github/workflows/cd-production.yml` | DevOps Team |
| Bicep IaC Modules | `/infra/` | Platform Team |
| Architecture Documentation | `/docs/architecture.md` | DevOps Team |
| Operations Runbook | `/docs/runbooks/operations.md` | DevOps Team |
| Incident Response Playbook | `/docs/runbooks/incident-response.md` | DevOps Team |
| Deployment Evidence (Screenshots) | `/docs/screenshots/` | DevOps Team |

### 11.2 Deployment Procedure (Post-Handover)

1. Developer creates a feature branch from `main`.
2. Code changes are committed (GPG-signed) and a Pull Request is raised.
3. CI pipeline runs automatically — CodeQL, unit tests, and secret scanning must pass.
4. Minimum 2 code owners approve the Pull Request.
5. PR is merged to `main` by an authorized `release-managers` team member.
6. CD pipeline triggers automatically, awaiting `release-managers` approval in the GitHub Production environment.
7. Upon approval, deployment proceeds; health check validates successful deployment.
8. Release tag is automatically created in the repository.

### 11.3 Monitoring & Alerting

| Alert | Trigger | Notification Channel |
|---|---|---|
| Application Error Rate > 1% | Application Insights | Microsoft Teams — `#fintech-ops` |
| HTTP 5xx Response > 5/min | Application Insights | PagerDuty (P1) |
| Pipeline Failure | GitHub Actions | Email + Teams webhook |
| Secret Scanning Alert | GitHub GHAS | Security Team Email |
| Dependabot Critical CVE | GitHub GHAS | `#fintech-security` Teams channel |

---

## 12. Lessons Learned & Optimization Roadmap

### 12.1 Lessons Learned

| Observation | Impact | Recommendation |
|---|---|---|
| OIDC adoption eliminated credential rotation overhead | High | Standardize OIDC across all Azure workloads |
| GitHub Copilot reduced IaC authoring time significantly | Medium | Expand to documentation and runbook generation |
| Branch protection prevented 3 unreviewed code merges in UAT | High | Apply equivalent policies to all repositories |
| Bicep `what-if` deployments caught 2 breaking infra changes pre-production | High | Mandate `what-if` as a required CI gate for infra PRs |
| Early GHAS enablement surfaced 4 legacy secrets in commit history | High | Enable Secret Scanning push protection from Day 0 |

### 12.2 Optimization Roadmap (Phase 2)

| Initiative | Priority | Estimated Effort |
|---|---|---|
| Blue/Green deployment strategy via Azure Deployment Slots | High | 3 sprints |
| Dependabot auto-merge for patch-level updates | Medium | 1 sprint |
| Performance testing stage in CI (k6 or Azure Load Testing) | Medium | 2 sprints |
| GitHub Actions self-hosted runners on Azure Container Instances | Low | 2 sprints |
| Secrets rotation automation via Azure Automation + Key Vault | High | 3 sprints |

---

## 13. Compliance Mapping (Auditor Reference)

| Control ID | Requirement | Evidence Location | Status |
|---|---|---|---|
| 4.1.1 | GitHub Enterprise provisioned for customer | GitHub Organization: `GlobalFinTechSolutions` | ✅ Verified |
| 4.1.2 | Entra ID SSO configured | GitHub Org → Settings → Authentication Security → SAML SSO | ✅ Verified |
| 4.1.3 | GitHub Actions used for CI/CD | `.github/workflows/` — pipeline run history > 90 days | ✅ Verified |
| 4.1.4 | GitHub Copilot for Business enabled | GitHub Org → Settings → Copilot → Business license count: 12 | ✅ Verified |
| 4.1.5 | Copilot used in active development | Commit history referencing Copilot-assisted code; unit test coverage delta | ✅ Verified |
| 4.1.6 | Solution deployed to Microsoft Azure | Azure Resource Graph: `rg-fintech-prod-001` | ✅ Verified |
| 4.1.7 | IaC used for Azure provisioning | `/infra/` Bicep modules; Azure Deployment History | ✅ Verified |
| 4.1.8 | Security scanning integrated in pipeline | GitHub → Security → Code Scanning (CodeQL enabled) | ✅ Verified |

---

## 14. Appendix

### Appendix A — GitHub Repository Settings Screenshots

| Screenshot | Path |
|---|---|
| SAML SSO Configuration | `/docs/screenshots/01-saml-sso-config.png` |
| GHAS Enabled (Org Level) | `/docs/screenshots/02-ghas-org-enabled.png` |
| Branch Protection Rules | `/docs/screenshots/03-branch-protection-main.png` |
| GitHub Copilot Seat Assignments | `/docs/screenshots/04-copilot-seats.png` |
| Production Environment Approval | `/docs/screenshots/05-prod-environment-approval.png` |
| Successful CD Pipeline Run | `/docs/screenshots/06-cd-pipeline-success.png` |
| CodeQL Scan Results | `/docs/screenshots/07-codeql-results.png` |

### Appendix B — Azure Resource Validation Commands

```bash
# List all resources in the production resource group
az resource list \
  --resource-group rg-fintech-prod-001 \
  --output table

# Validate App Service is running
az webapp show \
  --name app-fintech-api-prod \
  --resource-group rg-fintech-prod-001 \
  --query "{name:name, state:state, hostName:defaultHostName}" \
  --output json

# Confirm Managed Identity is assigned
az webapp identity show \
  --name app-fintech-api-prod \
  --resource-group rg-fintech-prod-001

# Validate Key Vault private endpoint
az network private-endpoint show \
  --name pe-kv-fintech-prod-001 \
  --resource-group rg-fintech-prod-001 \
  --query "provisioningState"
```

### Appendix C — Glossary

| Term | Definition |
|---|---|
| GHAS | GitHub Advanced Security |
| OIDC | OpenID Connect — token-based authentication standard |
| IaC | Infrastructure as Code |
| RBAC | Role-Based Access Control |
| VNET | Azure Virtual Network |
| MSI | Managed Service Identity (Azure) |
| SAML | Security Assertion Markup Language |
| SCIM | System for Cross-domain Identity Management |
| SBOM | Software Bill of Materials |
| SAST | Static Application Security Testing |
| NSG | Network Security Group |
| ACR | Azure Container Registry |

---

*Document Version: 2.1 — Final Production Release*  
*Prepared For: Global FinTech Solutions Pte. Ltd.*  
*Prepared By: DevOps Modernization Practice — Microsoft Azure Partnership Team*  
*Classification: CONFIDENTIAL*  
*Date: February 28, 2026*

---

> **Disclaimer:** This document is prepared for the purposes of the Microsoft Azure Advanced Specialization audit. All configuration values, resource names, and identifiers referenced herein reflect the live production environment as of the engagement close date. Any changes to the environment post-handover are the responsibility of the customer operations team.
