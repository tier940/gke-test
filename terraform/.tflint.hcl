plugin "google" {
    enabled = true
    version = "0.16.1"
    source  = "github.com/terraform-linters/tflint-ruleset-google"
}

config {
    module = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_unused_required_providers" {
  enabled = true
}
