# --------------------------------------------------------------------------
# Outputs
# --------------------------------------------------------------------------

output "headnode_floating_ip" {
  description = "Head Node 的 Floating IP (SSH 入口)"
  value       = zillaforge_floating_ip.headnode.ip_address
}

output "default_network_ips" {
  description = "Head Node 與所有 Compute Node 在 default network 上的 IP"
  value = merge(
    { (zillaforge_server.headnode.name) = zillaforge_server.headnode.network_attachment[0].ip_address },
    { for s in zillaforge_server.compute : s.name => s.network_attachment[0].ip_address }
  )
}
