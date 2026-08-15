# CST8918 Final Project - Terraform, Azure AKS, and GitHub Actions

Capstone project for CST8918: use Terraform to provision Azure Kubernetes
Service (AKS) clusters and a managed Redis cache for the Remix Weather
Application (from Week 3), across `test` and `prod` environments, with
Terraform remote state in Azure Blob Storage and CI/CD via GitHub Actions.

## Team members

- Youssuf ([@YoussufAlgonquin](https://github.com/YoussufAlgonquin))
- Muhannad Jaber ([@muhannadj27](https://github.com/muhannadj27))
- Faiza ([@Faiza2201](https://github.com/Faiza2201))
- Idris Jovial Sop ([@sopn0001](https://github.com/sopn0001))

## Project structure

```plaintext
.
├── .github/
│   ├── workflows/
│   │   ├── static-tests.yml     # fmt, validate, tfsec — push to any branch
│   │   ├── pr-checks.yml        # tflint (+ terraform plan, stubbed) — PR to main
│   │   ├── infra-apply.yml      # terraform apply — push to main (stubbed)
│   │   ├── app-build-push.yml   # build/push image to ACR — PR to main (stubbed)
│   │   └── app-deploy.yml       # deploy to AKS test/prod (stubbed)
│   └── pull_request_template.md
├── app/                         # Remix Weather Application (to be added)
├── infra/
│   ├── tf-backend/              # Azure Storage backend bootstrap (applied manually, once)
│   ├── modules/
│   │   ├── network/              # resource group, VNet, 4 subnets
│   │   ├── aks/                  # AKS cluster (test: fixed 1 node; prod: autoscale 1-3)
│   │   └── weather-app/          # ACR, Redis, k8s deployment/service
│   └── envs/
│       ├── test/                # root module for the test environment
│       └── prod/                # root module for the prod environment
└── docs/
    └── task-breakdown.md         # what's left, and who's picking it up
```

## Status

This is the initial scaffolding: folder/module structure, CI workflow
files, and branch protection are in place. The Terraform resources
themselves, the app code, and the cloud-dependent workflow steps are not
implemented yet — see [docs/task-breakdown.md](docs/task-breakdown.md) for
the itemized list and claim a task before starting a branch.

## Branching workflow

- No direct pushes to `main` — it's protected by a ruleset (PR + 1
  approval from someone other than the author + passing status checks +
  branch up to date with `main`).
- One branch per feature/fix, kept small, e.g. `infra/network-module` or
  `app/copy-week3-app`.
- Infra changes and app changes go in separate PRs (the deploy workflows
  key off which paths changed).

## Running it locally

Once `infra/tf-backend` has been applied by whoever owns it, each
environment is applied from its own directory. **Apply `test` before
`prod`** (prod reads network/ACR from test remote state).

```sh
cd infra/envs/test   # then infra/envs/prod
terraform init
terraform plan
terraform apply
```

### First-time apply (empty environments)

The root modules configure the `kubernetes` provider from
`module.aks.kube_config`, which Terraform only knows after the AKS
cluster exists. On a brand-new environment, use a two-step apply:

```sh
# test
cd infra/envs/test
terraform apply -target=module.network -target=module.aks
terraform apply

# prod (after test state exists)
cd infra/envs/prod
terraform apply -target=module.aks
terraform apply
```

Later applies are a normal single `terraform apply`.

Azure CLI (`az login`) or the GitHub Actions OIDC identity (see
[docs/task-breakdown.md](docs/task-breakdown.md) item 8) provides the
credentials — no secrets are committed to this repo.
