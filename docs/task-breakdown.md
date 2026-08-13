# Task Breakdown

Working list of what's left, mapped to the assignment requirements. Each
row should become a GitHub Issue and a small PR (one feature/fix per
branch) - see the [README](../README.md) for the branching workflow.
Claim a task by assigning yourself the issue.

Repo scaffolding, branch protection ruleset, and this file were set up so
the team can divide work below - nothing past that has been implemented
yet.

| # | Task | Where | Status |
|---|------|-------|--------|
| 1 | Terraform backend: resource group, storage account, blob container | `infra/tf-backend` | Not started |
| 2 | Network module: resource group, VNet (10.0.0.0/14), 4 subnets | `infra/modules/network` | Not started |
| 3 | AKS module: cluster resource, node pool (fixed vs. autoscaling) | `infra/modules/aks` | Not started |
| 4 | Weather-app module: ACR, Redis cache, k8s deployment/service | `infra/modules/weather-app` | Not started |
| 5 | Wire up `infra/envs/test` root module (calls network + aks + weather-app) | `infra/envs/test` | Not started |
| 6 | Wire up `infra/envs/prod` root module | `infra/envs/prod` | Not started |
| 7 | Copy in the Week 3 Remix Weather App + Dockerfile | `app/` | Not started |
| 8 | Azure federated identities (OIDC) for GitHub Actions + repo/environment secrets | Azure + repo Settings | Not started |
| 9 | Complete `terraform-plan` job in `pr-checks.yml` once #1 and #8 are done, then add it as a required status check in the ruleset | `.github/workflows/pr-checks.yml` | Blocked on #1, #8 |
| 10 | Complete `infra-apply.yml` (apply on merge to main) | `.github/workflows/infra-apply.yml` | Blocked on #1, #8 |
| 11 | Complete `app-build-push.yml` (build/push image to ACR on PR) | `.github/workflows/app-build-push.yml` | Blocked on #4, #7, #8 |
| 12 | Complete `app-deploy.yml` (deploy to test on PR, prod on merge) | `.github/workflows/app-deploy.yml` | Blocked on #4, #7, #8 |

Already working today (no cloud credentials required):

- `static-tests.yml` - `terraform fmt`, `terraform validate`, `tfsec` on every push to any branch.
- `pr-checks.yml` - `tflint` on every PR to `main` (the `terraform-plan` job in the same file is a stub, see #9).

Verified end-to-end via [PR #1](../../pull/1): static tests, and tflint all ran and passed on a real pull request to `main`.
