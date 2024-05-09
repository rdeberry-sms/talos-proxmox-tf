resource "vsphere_virtual_machine" "nodes" {
  for_each                   = var.nodes
  name                       = each.value.name
  resource_pool_id           = data.vsphere_resource_pool.pool.id
  datastore_id               = data.vsphere_datastore.datastore.id
  folder                     = var.vsphere_folder
  guest_id                   = var.vm_linux_guest_id
  enable_disk_uuid           = true
  num_cpus                   = each.value.cpu
  memory                     = each.value.memory
  wait_for_guest_ip_timeout  = 0
  wait_for_guest_net_timeout = 0

  # wait_for_guest_net_timeout = 0
  disk {
    label       = var.vm_linux_disk_name
    size        = each.value.disk_size_0
    unit_number = var.first_disk_unit_number
  }

  dynamic "disk" {
    for_each = can(each.value["disk_size_1"]) ? [1] : []
    content {
      label       = var.vm_second_linux_disk_name
      unit_number = var.second_disk_unit_number
      size        = each.value.disk_size_1
    }
  }

  network_interface {
    network_id = data.vsphere_network.network.id


  }
  cdrom {
    client_device = false
    datastore_id  = data.vsphere_datastore.datastore.id
    path          = "ISO-exchange/metal-amd64.iso"
  }
  lifecycle {
    ignore_changes = [
      hv_mode,
      ept_rvi_mode,
    ]
  }
}
