variable "kubernetes" {
  description = "Map of Kubernetes specific params for Talos"
  type        = map(string)
  default = {
    hostname                = ""
    podSubnets              = "10.244.0.0/16"
    serviceSubnets          = "10.96.0.0/12"
    domain                  = "cluster.local"
    apiDomain               = ""
    ipv4_local              = ""
    ipv4_vip                = ""
    talos-version           = ""
    metallb_l2_addressrange = ""
    registry-endpoint       = ""
    identity                = ""
    identitypub             = ""
    knownhosts              = ""
    px_region               = ""
    px_node                 = ""
    sidero-endpoint         = ""
    storageclass            = ""
    storageclass-xfs        = ""
    cluster-0-vip           = ""
  }
}

variable "worker_tags" {
  description = "Tags for workers"
  type        = string
  default     = "kubernetes,worker"
}
variable "cp_tags" {
  description = "Tags for CP"
  type        = string
  default     = "kubernetes,cp"
}

variable "cluster_name" {
  description = "A name to provide for the Talos cluster"
  type        = string
}

variable "region" {
  description = "A name to provide for the Talos cluster"
  type        = string
}

variable "pool" {
  description = "A name to provide for the Talos cluster"
  type        = string
  default     = ""
}

variable "cluster_endpoint" {
  description = "A name to provide for the Talos cluster"
  type        = string
}

variable "talos_version" {
  description = "A name to provide for the Talos cluster"
  type        = string
}

variable "k8s_version" {
  description = "A name to provide for the Talos cluster"
  type        = string
}

variable "proxmox_api_url" {
  description = "Proxmox host"
  type        = string
}

variable "storage_name" {
  description = "Name of Storage Device"
  type        = string
}

variable "proxmox_token_id" {
  description = "Proxmox token id"
  type        = string
}

variable "proxmox_token_secret" {
  description = "Proxmox token secret"
  type        = string
}

variable "private_key_file_path" {
  description = "Private Key Path"
  type        = string
}

variable "public_key_file_path" {
  description = "Public Key Path"
  type        = string
}

variable "known_hosts" {
  description = "Known Hosts SSH"
  type        = string
  default     = ""
}

variable "dns_server" {
  description = "IP/FQDN of DNS server"
  type        = string
  default     = ""
}

variable "ntpserver" {
  description = "IP/FQDN of NTP server"
  type        = string
  default     = ""
}

variable "control_plane_nodes" {
  description = "vm variables in a dictionary "
  type        = map(any)
  default = {
    target_node = ""
    cores       = ""
    memory      = ""
    disk_size   = ""
    name        = ""
    ip1_address = ""
    gw          = ""
    ip1_netmask = ""
    sockets     = ""
    os_type     = ""
  }
}

variable "worker_nodes" {
  description = "vm variables in a dictionary "
  type        = map(any)
  default = {
    target_node = ""
    cores       = ""
    memory      = ""
    disk_size   = ""
    name        = ""
    ip1_address = ""
    gw          = ""
    ip1_netmask = ""
    sockets     = ""
    os_type     = ""
  }
}

variable "network_bridge" {
  description = "Network bridge name"
  default     = "vmbr0"
  type        = string
}

variable "primary_vlan" {
  description = "Primary vlan for primary interface"
  type        = number
  default     = null
}

variable "virtual_interface" {
  description = "What virtual HW for disk"
  type        = string
  default     = "virtio"
}

variable "worker_machine_type" {
  description = "Worker Machine Type"
  default     = "worker"
  type        = string
}

variable "cp_machine_type" {
  description = "CP Machine Type"
  default     = "controlplane"
  type        = string
}

variable "agent" {
  description = "agent"
  type        = number
  default     = "1"
}

variable "vm_state" {
  description = "state of the VM"
  type        = string
  default     = "running"
}

variable "os_type" {
  description = "OS Type"
  type        = string
  default     = "cloud-init"
}

variable "cpu" {
  description = "Dont Change for host"
  type        = string
  default     = "host"
}

variable "onboot" {
  description = "OS Type"
  type        = bool
  default     = "true"
}

variable "scsihw" {
  default     = "virtio-scsi-single"
  description = "What type of SCSI HW"
  type        = string
}

variable "boot_order" {
  default     = "order=scsi0"
  description = "What type of SCSI HW"
  type        = string
}

variable "random_integer_ceiling_worker" {
  description = "High vmid"
  type        = number
  default     = 8000
}

variable "random_integer_floor_worker" {
  description = "Low vmid"
  type        = number
  default     = 6000
}

variable "random_integer_ceiling_master" {
  description = "High vmid"
  type        = number
  default     = 4000
}

variable "random_integer_floor_master" {
  description = "Low vmid"
  type        = number
  default     = 2000
}

variable "secondary_vlan" {
  description = "Secondary vlan for 2nd interface"
  type        = number
  default     = 0
}
