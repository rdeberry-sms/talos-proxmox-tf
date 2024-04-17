output "talosconfig" {
  description = "Talos Config"
  value       = data.talos_client_configuration.cc.talos_config
  sensitive   = true
}

output "cp" {
  description = "Control Plane Machine Configuration"
  value = {
    for name, mc in data.talos_machine_configuration.cp : name => mc.machine_configuration
  }
  sensitive = true
}

output "worker" {
  description = "Worker Machine Configurations"
  value = {
    for name, worker in data.talos_machine_configuration.workers : name => worker.machine_configuration
  }
  sensitive = true
}


#output "cp" {
#  value     = data.talos_machine_configuration.mc.machine_configuration
#  sensitive = true
#}
#
#output "worker" {
#  value     = data.talos_machine_configuration.workers.machine_configuration
#  sensitive = true
#}
