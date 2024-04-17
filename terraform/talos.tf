resource "talos_machine_secrets" "secrets" {}


data "talos_machine_configuration" "cp" {
  for_each = var.control_plane_nodes

  cluster_name       = var.cluster_name
  machine_type       = var.cp_machine_type
  cluster_endpoint   = var.cluster_endpoint
  machine_secrets    = talos_machine_secrets.secrets.machine_secrets
  kubernetes_version = var.k8s_version
  talos_version      = var.talos_version
  config_patches = [
    templatefile("${path.module}/templates/controlplane.yaml.tpl",
      merge(var.kubernetes, {
        hostname         = proxmox_vm_qemu.controlplanes[each.key].name
        ipv4_local       = split("/", split("=", proxmox_vm_qemu.controlplanes[each.key].ipconfig0)[1])[0]
        identity         = file(var.private_key_file_path)
        identitypub      = file(var.public_key_file_path)
        knownhosts       = var.known_hosts
        px_region        = var.region
        px_node          = each.value.target_node
        storageclass     = var.storage_name
        storageclass-xfs = var.storage_name
        nameserver       = var.dns_server
        ntpserver        = var.ntpserver
        clusters = yamlencode({
          clusters = [
            {
              token_id     = var.proxmox_token_id
              token_secret = var.proxmox_token_secret
              url          = var.proxmox_api_url
              region       = var.region
            },
          ]
        })
        pxcreds = yamlencode({
          clusters = {
            cluster-1 = {
              api_token_id     = var.proxmox_token_id
              api_token_secret = var.proxmox_token_secret
              api_url          = var.proxmox_api_url
              pool             = var.pool
            }
          }
        })
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
  for_each                    = var.control_plane_nodes
  depends_on                  = [proxmox_vm_qemu.controlplanes]
  client_configuration        = talos_machine_secrets.secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.cp[each.key].machine_configuration
  node                        = split("/", split("=", proxmox_vm_qemu.controlplanes[each.key].ipconfig0)[1])[0]
}


resource "talos_machine_bootstrap" "bootstrap" {
  depends_on = [
    talos_machine_configuration_apply.cp_apply
  ]
  node                 = local.first_controlplane_ip
  client_configuration = talos_machine_secrets.secrets.client_configuration
}

locals {
  first_controllpane    = element(keys(proxmox_vm_qemu.controlplanes), 0)
  first_controlplane_ip = split("/", split("=", proxmox_vm_qemu.controlplanes[local.first_controllpane].ipconfig0)[1])[0]
}


data "talos_machine_configuration" "workers" {
  for_each = var.worker_nodes

  cluster_name       = var.cluster_name
  machine_type       = var.worker_machine_type
  cluster_endpoint   = var.cluster_endpoint
  machine_secrets    = talos_machine_secrets.secrets.machine_secrets
  kubernetes_version = var.k8s_version
  talos_version      = var.talos_version
  config_patches = [
    templatefile("${path.module}/templates/worker.yaml.tpl",
      merge(var.kubernetes, {
        hostname   = proxmox_vm_qemu.workers[each.key].name
        ipv4_local = split("/", split("=", proxmox_vm_qemu.workers[each.key].ipconfig0)[1])[0]
        px_region  = var.region
        px_node    = each.value.target_node
        nameserver = var.dns_server
        ntpserver  = var.ntpserver
      })
    )
  ]
}


resource "talos_machine_configuration_apply" "worker_apply" {
  for_each = var.worker_nodes

  depends_on                  = [proxmox_vm_qemu.workers]
  client_configuration        = talos_machine_secrets.secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.workers[each.key].machine_configuration
  node                        = split("/", split("=", proxmox_vm_qemu.workers[each.key].ipconfig0)[1])[0]
}
