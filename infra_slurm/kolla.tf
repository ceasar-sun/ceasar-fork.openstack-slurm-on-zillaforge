# --------------------------------------------------------------------------
# Generate Slurm partition inventory files from templates
# --------------------------------------------------------------------------

resource "local_file" "compute_odd" {
  content = templatefile("${path.module}/templates/07-compute-odd.tpl", {
    compute_nodes = [
      for i, s in zillaforge_server.compute : {
        name = s.name
        ip   = s.network_attachment[0].ip_address
      }
      if(i + 2) % 2 == 1
    ]
  })
  filename = "${path.module}/../kolla-ansible/etc/kolla/inventroy/07-compute-odd"
}

resource "local_file" "compute_even" {
  content = templatefile("${path.module}/templates/08-compute-even.tpl", {
    compute_nodes = [
      for i, s in zillaforge_server.compute : {
        name = s.name
        ip   = s.network_attachment[0].ip_address
      }
      if(i + 2) % 2 == 0
    ]
  })
  filename = "${path.module}/../kolla-ansible/etc/kolla/inventroy/08-compute-even"

}

module "sync_project" {
  source = "../modules/sync_project"

  depends_on = [local_file.compute_even, local_file.compute_odd]

  project_root    = local.project_root
  cloud_user      = local.cloud_user
  server_password = var.server_password
  target_host     = zillaforge_floating_ip.headnode.ip_address
}