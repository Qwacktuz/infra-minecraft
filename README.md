# Minecraft SMP

Minecraft + IaC = ❤️

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

# Spin up stack/stop stack
docker compose down
docker compose up -d
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

- Move stack to Terraform or OpenTofu
- Implement pelican Panel or Pterodactyl installation
- Add instance to a tailnet
- Look for further hardening
