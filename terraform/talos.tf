data "vsphere_virtual_machine" "nodes" {
  depends_on    = [vsphere_virtual_machine.nodes]
  for_each      = var.nodes
  name          = each.value.name
  datacenter_id = data.vsphere_datastore.datastore.datacenter_id
}

resource "talos_machine_secrets" "secrets" {}


data "talos_machine_configuration" "cp" {
  depends_on = [vsphere_virtual_machine.nodes]
  for_each = {
    for name, node in var.nodes :
    node.k8s_role == "cp" ? name : null => node
    if node.k8s_role == "cp"
  }

  cluster_name       = var.cluster_name
  machine_type       = var.cp_machine_type
  cluster_endpoint   = var.cluster_endpoint
  machine_secrets    = talos_machine_secrets.secrets.machine_secrets
  kubernetes_version = var.k8s_version
  talos_version      = var.talos_version
  config_patches = [
    templatefile("${path.module}/templates/controlplane.yaml.tpl",
      merge(var.kubernetes, {
        hostname    = each.value["name"]
        ipv4_addr   = each.value["ip_address"]
        identity    = file(var.private_key_file_path)
        identitypub = file(var.public_key_file_path)
        knownhosts  = var.known_hosts
        nameserver  = var.dns_server
        ntpserver   = var.ntpserver
        gateway     = each.value.gateway
      })
    )
  ]
}


data "talos_client_configuration" "cc" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.secrets.client_configuration
  nodes                = [var.kubernetes["ipv4_vip"], local.first_controlplane_ip]
  endpoints            = [var.kubernetes["ipv4_vip"], local.first_controlplane_ip]
}


resource "talos_machine_configuration_apply" "cp_apply" {
  depends_on = [vsphere_virtual_machine.nodes, data.vsphere_virtual_machine.nodes]
  for_each = {
    for name, node in var.nodes :
    node.k8s_role == "cp" ? name : null => node
    if node.k8s_role == "cp"
  }
  client_configuration        = talos_machine_secrets.secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.cp[each.key].machine_configuration
  node                        = data.vsphere_virtual_machine.nodes[each.key].default_ip_address
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on = [
    talos_machine_configuration_apply.cp_apply, talos_machine_configuration_apply.worker_apply
  ]
  node                 = local.first_controlplane_ip
  client_configuration = talos_machine_secrets.secrets.client_configuration
}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [vsphere_virtual_machine.nodes]

  create_duration = "60s"
}


data "talos_machine_configuration" "workers" {
  depends_on = [vsphere_virtual_machine.nodes]
  for_each = {
    for name, node in var.nodes :
    node.k8s_role == "worker" ? name : null => node
    if node.k8s_role == "worker"
  }

  cluster_name       = var.cluster_name
  machine_type       = var.worker_machine_type
  cluster_endpoint   = var.cluster_endpoint
  machine_secrets    = talos_machine_secrets.secrets.machine_secrets
  kubernetes_version = var.k8s_version
  talos_version      = var.talos_version
  config_patches = [
    templatefile("${path.module}/templates/worker.yaml.tpl",
      merge(var.kubernetes, {
        hostname   = each.value["name"]
        ipv4_addr  = each.value["ip_address"]
        nameserver = var.dns_server
        ntpserver  = var.ntpserver
        gateway    = each.value.gateway
      })
    )
  ]
}


resource "talos_machine_configuration_apply" "worker_apply" {
  depends_on = [vsphere_virtual_machine.nodes, data.vsphere_virtual_machine.nodes]
  for_each = {
    for name, node in var.nodes :
    node.k8s_role == "worker" ? name : null => node
    if node.k8s_role == "worker"
  }
  client_configuration        = talos_machine_secrets.secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.workers[each.key].machine_configuration
  node                        = data.vsphere_virtual_machine.nodes[each.key].default_ip_address


}
locals {
  first_controlplane_name = element(keys(vsphere_virtual_machine.nodes), 0)
  first_controlplane_ip   = var.nodes[local.first_controlplane_name].ip_address
}
