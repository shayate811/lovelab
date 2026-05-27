output "node_ips" {
  value = { for k, v in var.nodes : k => v.ip }
}
