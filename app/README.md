## Commands

**Quick commands for management**

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

```

**Backup management**

```bash
# Force backup
docker compose exec backup backup now

# View snapshots
docker compose exec backup restic snapshots

# Delete specific snapshot (remove reference)
docker compose exec backup restic forget <snapshot_id>

# Keep ONLY last backup
docker compose exec backup restic forget --keep-last 1 --prune

# Actually delete data
docker compose exec backup restic prune

# Verify restic integrity
docker compose exec backup restic check
# List backed up files
docker compose exec backup restic ls latest

# Download latest snapshot (test restore)
mkdir -p ~/app/restic-restore-test
docker compose run --rm --no-deps \
    -v ~/app/restic-restore-test:/restore \
    --entrypoint restic backup \
    restore latest --target /restore
ls -la ~/app/restic-restore-test/data
```

### How to get old java console window (beware CTRL-C)

Add this to `compose.yml`

```yaml
environment:
      ...
    stdin_open: true  # Allows you to send input
    tty: true        # Allows you to see output
```

and execute `docker attach minecraft-service` in a shell
