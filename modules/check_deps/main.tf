terraform {
  required_providers {
    external = {
      source  = "hashicorp/external"
      version = ">= 2.3.0"
    }
  }
}

data "external" "check_deps" {
  program = ["bash", "${path.module}/check_deps.sh"]
  query   = {}
}
