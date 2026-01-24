variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "tailscale_auth_key" {
  description = "Tailscale Auth Key (Ephemeral, Pre-authorized)"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "Public SSH key for access"
  type        = string
}

variable "server_name" {
  description = "Hostname of the server"
  type        = string
  default     = "mc-prod"
}

variable "server_type" {
  description = "Instance type"
  type        = string
  default     = "cax21" # ARM64, 4 vCPU, 4GB RAM
}

variable "location" {
  description = "Datacenter location"
  type        = string
  default     = "hel1"
}

variable "username" {
  description = "The non-root user to create (must match GitHub vars)"
  type        = string
  default     = "deploy"
}
