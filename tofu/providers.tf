terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.25.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.0"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "tailscale" {
  token = var.tailscale_auth_key
}
