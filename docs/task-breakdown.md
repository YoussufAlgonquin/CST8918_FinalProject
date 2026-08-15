# Task Breakdown

Working list of what's left, mapped to the assignment requirements. Each
row should become a GitHub Issue and a small PR (one feature/fix per
branch) - see the [README](../README.md) for the branching workflow.
Claim a task by assigning yourself the issue.

All infrastructure is live: `test` and `prod` are both deployed to Azure
(resource group `cst8918-final-project-group-6`), the app is running in
both, and the CI/CD workflows below are wired up with real Azure
federated identities.

| # | Task | Where | Status |
|---|------|-------|--------|
| 1 | Terraform backend: resource group, storage account, blob container | `infra/tf-backend` | Done ([#13](../../pull/13)) - applied |
| 2 | Network module: resource group, VNet (10.0.0.0/14), 4 subnets | `infra/modules/network` | Done ([#13](../../pull/13)) - applied |
| 3 | AKS module: cluster resource, node pool (fixed vs. autoscaling) | `infra/modules/aks` | Done ([#14](../../pull/14)) - applied to both envs |
| 4 | Weather-app module: ACR, Redis cache, k8s deployment/service | `infra/modules/weather-app` | Done ([#18](../../pull/18)) - applied to both envs |
| 5 | Wire up `infra/envs/test` root module (calls network + aks + weather-app) | `infra/envs/test` | Done ([#18](../../pull/18)) - applied |
| 6 | Wire up `infra/envs/prod` root module | `infra/envs/prod` | Done ([#18](../../pull/18), [#25](../../pull/25)) - applied |
| 7 | Copy in the Week 3 Remix Weather App + Dockerfile | `app/` | Done ([#15](../../pull/15)) |
| 8 | Azure federated identities (OIDC) for GitHub Actions + repo/environment secrets | Azure + repo Settings | Done - `cst8918fp-gha-r` (Reader, plan-only) and `cst8918fp-gha-rw` (Contributor + AcrPush + User Access Administrator, deploy/apply) |
| 9 | Complete `terraform-plan` job in `pr-checks.yml`, add as required status check | `.github/workflows/pr-checks.yml` | Done - live-verified via PR #24 |
| 10 | Complete `infra-apply.yml` (apply on merge to main) | `.github/workflows/infra-apply.yml` | Done - live-verified deploying prod from scratch |
| 11 | Complete `app-build-push.yml` (build/push image to ACR on PR) | `.github/workflows/app-build-push.yml` | Done - live-verified via PR #24 |
| 12 | Complete `app-deploy.yml` (deploy to test on PR, prod on merge) | `.github/workflows/app-deploy.yml` | Done - live-verified via PR #24 |

## Known platform constraints (not bugs - real Azure/subscription limits hit while deploying)

- **Kubernetes 1.32 → 1.34**: Azure moved 1.31-1.33 to LTS-only (paid Premium tier) since the assignment was written. `infra/modules/aks` defaults to 1.34, the oldest version still on the free standard support plan.
- **Standard_B2s → Standard_B2s_v2**: this subscription's allowed SKU list for `canadacentral` only includes the `_v2` generation.
- **Prod's app service is ClusterIP, not LoadBalancer**: Azure for Students caps this subscription at 3 public IPs per region. Test's AKS cluster egress + test's app LoadBalancer + prod's AKS cluster egress already use all 3, leaving none for a fourth (prod's app). Prod is reachable via `kubectl port-forward svc/weather-app 8080:80` (or `kubectl exec`) against the `cst8918-g6-prod-aks` cluster. See `infra/modules/weather-app/variables.tf` (`service_type`).

## Verified end-to-end

- Test: `http://<test LoadBalancer IP - see infra/envs/test output weather_app_service_ip>` serves real weather data via the deployed app, Redis-backed cache.
- Prod: same app, same real weather data, confirmed via `kubectl port-forward` (see constraint above).
- A real PR (#24) exercised the full pipeline for real: `tflint`/`tfsec`/`fmt`/`validate` static checks, `terraform-plan` against live Azure state, Docker build + push to ACR, and deploy-to-test - all via the federated OIDC identities, no long-lived credentials anywhere.
- A real merge to `main` (PR #24) triggered `infra-apply.yml`, which deployed the `prod` environment from scratch (AKS, ACR role assignment, Redis, k8s deployment/service).
