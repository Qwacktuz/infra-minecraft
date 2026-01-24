# Layering the deployment

## OpenTofu (terraform) - Manage the (virtual) hardware

**Infrastucture layer**

- Hetzner server
  - Network
    - Firewall
  - Volumes
  - SSH Keys

**Bootstrap layer**

- OS user
- Docker installation (rootless setup)
- Tailscale
- Firewall (ufw)
- Directory layout (`~/mc-prod`)

## GitOps

- Everything else
