#!/bin/bash
set -e

echo "⚠️  --- DANGER: MINECRAFT RESTORE SCRIPT ---"
echo "This will STOP the server and replace the current world data."
echo ""

# 1. Select Snapshot
docker compose run --rm --entrypoint restic backup -r rclone:r2:cactuz-mc-backups snapshots
echo ""
read -r -p "Enter Snapshot ID to restore (or type 'latest'): " SNAP_ID

if [ -z "$SNAP_ID" ]; then
  echo "❌ No ID entered. Exiting."
  exit 1
fi

read -r -p "Are you sure you want to overwrite production data with snapshot '$SNAP_ID'? [y/N]: " confirm
if [[ ! $confirm =~ ^[yY] ]]; then
  echo "❌ Aborted."
  exit 0
fi

# 2. Stop Server
echo "🛑 Stopping Minecraft Server..."
docker compose stop minecraft-service

# 3. Safety Swap (Preserve broken state)
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
echo "📦 Moving current data to 'data/minecraft_pre_restore_$TIMESTAMP'..."
mv data/minecraft "data/minecraft_pre_restore_$TIMESTAMP"
mkdir -p data/minecraft

# 4. Restore
echo "📥 Restoring data from Cloudflare..."
# Restore to / because the backup path inside the repo is /data
docker compose run --rm --entrypoint restic backup \
  -r rclone:r2:cactuz-mc-backups restore "$SNAP_ID" --target /

# 5. Fix Permissions
echo "🔧 Fixing file permissions (uid:1000)..."
# Run a tiny alpine container to ensure the restored files belong to the correct user
docker run --rm -v "$(pwd)/data/minecraft:/data" alpine chown -R 1000:1000 /data

# 6. Restart
echo "🚀 Starting Minecraft Server..."
docker compose up -d minecraft-service

echo "✅ Restore Complete!"
echo "Old data saved at: data/minecraft_pre_restore_$TIMESTAMP"
echo "Monitoring logs for 10 seconds..."
timeout 10s docker compose logs -f minecraft-service || true
