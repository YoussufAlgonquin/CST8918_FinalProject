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
| 1 | Terraform backend: resource group, storage account, blob container | `infra/tf-backend` | Done ([#13](../../pull/13)) |
| 2 | Network module: resource group, VNet (10.0.0.0/14), 4 subnets | `infra/modules/network` | Done ([#13](../../pull/13)) - see PR comments on how envs should consume it |
| 3 | AKS module: cluster resource, node pool (fixed vs. autoscaling) | `infra/modules/aks` | Done ([#14](../../pull/14)) |
| 4 | Weather-app module: ACR, Redis cache, k8s deployment/service | `infra/modules/weather-app` | In review ([#17](../../pull/17)) |
| 5 | Wire up `infra/envs/test` root module (calls network + aks + weather-app) | `infra/envs/test` | In review ([#18](../../pull/18)) - addressing review comments |
| 6 | Wire up `infra/envs/prod` root module | `infra/envs/prod` | In review ([#18](../../pull/18)) - same as #5 |
| 7 | Copy in the Week 3 Remix Weather App + Dockerfile | `app/` | Done ([#15](../../pull/15)) |
| 8 | Azure federated identities (OIDC) for GitHub Actions + repo/environment secrets | Azure + repo Settings | Not started |
| 9 | Complete `terraform-plan` job in `pr-checks.yml` once #1 and #8 are done, then add it as a required status check in the ruleset | `.github/workflows/pr-checks.yml` | Blocked on #8 |
| 10 | Complete `infra-apply.yml` (apply on merge to main) | `.github/workflows/infra-apply.yml` | Blocked on #8 |
| 11 | Complete `app-build-push.yml` (build/push image to ACR on PR) | `.github/workflows/app-build-push.yml` | Blocked on #4, #8 |
| 12 | Complete `app-deploy.yml` (deploy to test on PR, prod on merge) | `.github/workflows/app-deploy.yml` | Blocked on #4, #8 |

Already working today (no cloud credentials required):

- `static-tests.yml` - `terraform fmt`, `terraform validate`, `tfsec` on every push to any branch.
- `pr-checks.yml` - `tflint` on every PR to `main` (the `terraform-plan` job skips until Azure OIDC secrets exist).

Verified end-to-end via [PR #1](../../pull/1): static tests, and tflint all ran and passed on a real pull request to `main`.
