# data "hcloud_ssh_key" "admin_key" {
# existing key in hetzner console
# name = "TODO"
# }

# Use resource "hcloud_ssh_key" to upload public ssh key
resource "hcloud_ssh_key" "default" {
  name       = "terraform-key"
  public_key = var.ssh_public_key
}

resource "hcloud_firewall" "mc_firewall" {
  name = "minecraft-fw"

  # Allow Minecraft TCP
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "25565"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Allow Minecraft UDP (Voice chat / Bedrock)
  rule {
    direction = "in"
    protocol  = "udp"
    port      = "25565"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Simple Voice Chat UDP default
  rule {
    direction = "in"
    protocol  = "udp"
    port      = "24454"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Note: Metrics/Grafana ports are NOT opened here 
  # because you access them via Tailscale IP in your compose.yml
}

resource "hcloud_server" "mc_node" {
  name         = var.server_name
  image        = "ubuntu-24.04"
  server_type  = var.server_type
  location     = var.location
  ssh_keys     = [hcloud_ssh_key.default.id]
  firewall_ids = [hcloud_firewall.mc_firewall.id]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  # Inject the Cloud-init configuration
  user_data = templatefile("${path.module}/cloud-init.yaml", {
    username           = var.username
    ssh_public_key     = var.ssh_public_key
    tailscale_auth_key = var.tailscale_auth_key
    hostname           = var.server_name
  })

  # Prevent accidental destruction of the production server
  lifecycle {
    prevent_destroy = false # Set to true once you are stable
  }
}
