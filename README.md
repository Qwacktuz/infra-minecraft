# Minecraft SMP

Minecraft + IaC = ❤️

GitOps minecraft infrastructure as code for cloud agnostic deployments secured through Tailscale and docker rootless. Now featuring incremental restic backups to cloudflare R2 bucket.

## Commands

Quick commands for management

```bash
# Drop into container
docker exec -it <container-name> bash

# Execute in game commands (RCON)
docker exec -it <container-name> rcon-cli

# List all running containers
docker ps

# List container logs
docker logs <container-name>

# List logs from a compose service
docker compose logs -f <service-name>

# Minecraft healthcheck
docker container inspect -f "{{.State.Health.Status}}" <container-name>

# Spin up stack/stop stack
docker compose up -d
docker compose down

# Verify restic integrity
docker compose exec backups restic check
docker compose exec backups restic ls latest
```

### How to get old java console vibe (beware CTRL-C)

Add this to `compose.yml`

```yaml
environment:
      ...
    stdin_open: true  # Allows you to send input
    tty: true        # Allows you to see output
```

and execute `docker attach mc` in a shell

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
