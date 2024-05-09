variable "kubernetes" {
  description = "Map of Kubernetes specific params for Talos"
  type        = map(string)
  default = {
    hostname                = ""
    podSubnets              = "10.244.0.0/16"
    serviceSubnets          = "10.96.0.0/12"
    domain                  = "cluster.local"
    apiDomain               = "api.cluster.local"
    ipv4_local              = ""
    ipv4_vip                = ""
    talos-version           = ""
    metallb_l2_addressrange = ""
    registry-endpoint       = ""
    identity                = ""
    identitypub             = ""
    knownhosts              = ""
    sidero-endpoint         = ""
    storageclass            = ""
    storageclass-xfs        = ""
    cluster-0-vip           = ""
  }
}

variable "cluster_name" {
  description = "A name to provide for the Talos cluster"
  type        = string
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


variable "vsphere_datacenter" {
  description = "The name of the datacenter. This can be a name or path. Can be omitted if there is only one datacenter in the inventory"
  type        = string
}

variable "vsphere_folder" {
  description = "The path to the virtual machine folder in which to place the virtual machine, relative to the datacenter path (/<datacenter-name>/vm). For example, /dc-01/vm/foo"
  type        = string
}

variable "vsphere_network" {
  description = "The name of the network. This can be a name or path"
  type        = string
}

variable "vm_linux_disk_name" {
  description = "Name of Scsi/ssd disk"
  type        = string
  default     = "disk0"
}

variable "vm_second_linux_disk_name" {
  description = "Name of Scsi/ssd disk"
  type        = string
  default     = "disk1"
}

variable "first_disk_unit_number" {
  description = "Name of Scsi/ssd disk"
  type        = number
  default     = 0
}

variable "second_disk_unit_number" {
  description = "Name of Scsi/ssd disk"
  type        = number
  default     = 1
}

variable "vm_linux_guest_id" {
  description = "Name of guest id type"
  type        = string
  default     = "rhel8_64Guest"
  validation {
    condition     = var.vm_linux_guest_id == "rhel8_64Guest" || var.vm_linux_guest_id == "rhel9_64Guest"
    error_message = "The guest OS type must be either 'rhel8_64Guest' or 'rhel9_64Guest'."
  }
}

variable "vsphere_cluster" {
  description = "The name or absolute path to the cluster"
  type        = string
}

variable "vsphere_datastore" {
  description = "The name of the datastore. This can be a name or path"
  type        = string
}




variable "nodes" {
  description = "Nodes"
  type        = map(any)
  default = {
    name           = "test"
    ip_address     = "1.1.1.1"
    netmask        = "32"
    gateway        = "1.1.1.2"
    dns_server     = "1.1.1.10"
    disk_size_0    = 20
    cpu            = 4
    memory         = 8192
    clone_template = "talos"
    k8s_role       = "cp"
    guest_id       = "rhel8_64Guest"
  }
}

variable "cp_machine_type" {
  type        = string
  default     = "controlplane"
  description = "CP Machine Type"
}

variable "worker_machine_type" {
  type        = string
  default     = "worker"
  description = "Worker Machine Type"
}
