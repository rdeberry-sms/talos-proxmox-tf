# TF setup

terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc1"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~>2"
    }
    null = {
      source  = "hashicorp/null"
      version = "~>3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_token_id
  pm_api_token_secret = var.proxmox_token_secret
  pm_timeout          = "2000"
}
