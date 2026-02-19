#!/bin/bash
set -e

cd "$HOME/app" || exit 1

echo "⚠️  --- DANGER: MINECRAFT RESTORE SCRIPT ---"
echo "This will STOP the server and replace the current world data."

# 1. Select Snapshot
docker compose run --rm --no-deps --entrypoint restic backup -r rclone:r2:cactuz-mc-backups snapshots
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

# 3. Safety Swap
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
echo "📦 Moving current data to 'data/minecraft_pre_restore_$TIMESTAMP'..."
if [ -d "data/minecraft" ]; then
  mv data/minecraft "data/minecraft_pre_restore_$TIMESTAMP"
fi
mkdir -p data/minecraft

# 4. Restore
echo "📥 Restoring data natively to root path..."
docker compose run --rm --no-deps \
  -v "$(pwd)/data/minecraft:/data" \
  --entrypoint restic \
  backup \
  -r "s3:${R2_ENDPOINT}/${R2_BUCKET_NAME}" restore "$SNAP_ID" --target /

# 5. Fix permissions
echo "🔧 Fixing permissions..."
chown -R 100999:100999 data/minecraft

# 4. Restore
# echo "📥 Restoring data from Cloudflare..."
# # We mount to /output. Restic restores the backup path, creating /output/data/...
# docker compose run --rm --no-deps \
#   -v "$(pwd)/data/minecraft:/output" \
#   --entrypoint restic \
#   backup \
#   -r rclone:r2:cactuz-mc-backups restore "$SNAP_ID" --target /output

# 5. Flatten and Fix Permissions (Inside Container)
# echo "🔧 Flattening structure and fixing permissions..."
# # We do this inside Alpine because the host shell lacks permissions to move files owned by sub-uids
# docker run --rm -v "$(pwd)/data/minecraft:/data" alpine sh -c "
#   if [ -d /data/data ]; then
#     echo 'Moving files out of nested data folder...'
#     find /data/data -mindepth 1 -maxdepth 1 -exec mv -t /data/ {} +
#     rmdir /data/data
#   fi
#   echo 'Setting ownership to 1000:1000...'
#   chown -R 1000:1000 /data
# "

# 6. Restart
echo "🚀 Starting Minecraft Server..."
docker compose up -d minecraft-service

echo "✅ Restore Complete!"
echo "Old data saved at: data/minecraft_pre_restore_$TIMESTAMP"
echo "Monitoring logs for 10 seconds..."
timeout 20s docker compose logs -f minecraft-service || true
