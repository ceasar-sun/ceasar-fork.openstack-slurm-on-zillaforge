terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.0"
    }
  }
}

variable "project_root" {
  type = string
}

variable "cloud_user" {
  type = string
}

variable "server_password" {
  type      = string
  sensitive = true
}

variable "target_host" {
  type = string
}

resource "null_resource" "sync_project" {
  triggers = {
    target_host  = var.target_host
    project_root = var.project_root
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOF
      set -euo pipefail
      command -v sshpass >/dev/null || { echo "sshpass is required to sync files"; exit 1; }
      sshpass -p "${var.server_password}" rsync -az --exclude '.git' -e "ssh -o StrictHostKeyChecking=no" "${var.project_root}/" "${var.cloud_user}@${var.target_host}:resource_manage/"
    EOF
  }
}
