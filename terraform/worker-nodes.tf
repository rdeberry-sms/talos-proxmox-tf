resource "proxmox_vm_qemu" "workers" {
  for_each                = var.worker_nodes
  name                    = each.value.name
  target_node             = each.value.target_node
  clone                   = each.value.os_type
  vmid                    = random_integer.worker_hosts[each.key].result
  agent                   = var.agent
  os_type                 = var.os_type
  ipconfig0               = "ip=${each.value.ip1_address}/${each.value.ip1_netmask},gw=${each.value.gw}"
  ipconfig1               = can(each.value["ip2_address"]) ? "ip=${each.value.ip2_address}/${each.value.ip2_netmask}" : null
  cloudinit_cdrom_storage = var.storage_name
  vm_state                = var.vm_state
  onboot                  = var.onboot
  cpu                     = var.cpu
  sockets                 = each.value.sockets
  cores                   = each.value.cores
  memory                  = each.value.memory
  scsihw                  = var.scsihw
  tags                    = var.worker_tags
  network {
    model  = var.virtual_interface
    bridge = var.network_bridge
    tag    = var.primary_vlan
  }
  dynamic "network" {
    for_each = can(each.value["ip2_address"]) ? [1] : []
    content {
      model  = var.virtual_interface
      bridge = var.network_bridge
      tag    = var.secondary_vlan
    }
  }
  nameserver = var.dns_server

  boot = var.boot_order
  disks {
    scsi {
      scsi0 {
        disk {

          size    = each.value.disk_size
          storage = var.storage_name
        }
      }
      dynamic "scsi1" {
        for_each = can(each.value["second_disk_size"]) ? [1] : []
        content {
          disk {
            size    = each.value.second_disk_size
            storage = var.storage_name
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      boot,
      network,
      desc,
      numa,
      agent,
      ipconfig0,
      ipconfig1,
      define_connection_info,
    ]
  }
}

resource "random_integer" "worker_hosts" {
  for_each = var.worker_nodes
  max      = var.random_integer_ceiling_worker
  min      = var.random_integer_floor_worker
}
