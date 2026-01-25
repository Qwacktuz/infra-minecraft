# Minecraft SMP

Minecraft + IaC = ❤️

GitOps minecraft infrastructure as code for cloud agnostic deployments secured through Tailscale and docker rootless. Now featuring incremental restic backups to cloudflare R2 bucket.

### How to download world

To for example prune manually with mcaselector

```bash
# Downlaod
ssh prd-hel1-mc-01 "cd ~/mc-prod && docker compose stop minecraft-service"
rsync -avzP prd-hel1-mc-01:~/mc-prod/data/minecraft/world/ ./local_minecraft_world/

# Upload
rsync -avzP ./local_minecraft_world/ prd-hel1-mc-01:~/mc-prod/data/minecraft/world_pruned/
# optionally move to world/ instead of world_pruned/

# Give Minecraft the correct permissions
# ssh into the VPS
ssh -t prd-hel1-mc-01 "sudo chown -R 100999:100999 ~/mc-prod/data/minecraft && echo '✅ success!'"
```

## TODO

- Implement Loki and Grafana Alloy
- Find a easier way to whitelist people -> portainer? 🤔
- Move stack to OpenTofu (OSS Terraform)
  - Implement pelican panel or pterodactyl panel
- Look for further hardening
  - Set up `tailscale cert <full-domain>` from the VPS to enable HTTPS with mDNS
- ~~Look into fastback (or equivalent) and remote off-site backups~~
- Refactor secrets management to use [docker compose secrets](https://docs.docker.com/compose/how-tos/use-secrets/) or maybe sops (my version is a bit hacky)

---

## Resources

- Running docker rootless <https://docs.docker.com/engine/security/rootless/>
