# --------------------------------------------------------------------------
# Generate Slurm partition inventory files from templates
# --------------------------------------------------------------------------

resource "local_file" "slurm_compute" {
  content = templatefile("${path.module}/templates/09-slurm-compute.tpl", {
    compute_nodes = [
      for i, s in zillaforge_server.compute : {
        name = s.name
        ip   = s.network_attachment[0].ip_address
      }
    ]
  })
  filename = "${path.module}/../kolla-ansible/etc/kolla/inventroy/09-slurm-compute"
}

module "sync_project" {
  source = "../modules/sync_project"

  depends_on = [local_file.slurm_compute]

  project_root    = local.project_root
  cloud_user      = local.cloud_user
  server_password = var.server_password
  target_host     = zillaforge_floating_ip.headnode.ip_address
}