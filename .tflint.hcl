plugin "azurerm" {
  enabled = true
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
  version = "0.28.0"
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

rule "terraform_naming_convention" {
  enabled = true
}

# Several modules currently declare variables ahead of the resources that
# will consume them (see docs/task-breakdown.md) - re-enable once those
# resources are implemented.
rule "terraform_unused_declarations" {
  enabled = false
}
