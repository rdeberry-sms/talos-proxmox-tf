# output "talosconfig" {
#   description = "Talos Config"
#   value       = data.talos_client_configuration.cc.talos_config
#   sensitive   = true
# }

# output "machine_conf_worker" {
#   description = "maching config for worker"
#   value       = data.talos_machine_configuration.workers
#   sensitive   = true
# }

# output "machine_conf_cp" {
#   description = "maching config for control plane"
#   value       = data.talos_machine_configuration.cp
#   sensitive   = true
# }

# output "ips" {
#   description = "IPs of Nodes"
#   value       = values(vsphere_virtual_machine.nodes).*.default_ip_address
# }
