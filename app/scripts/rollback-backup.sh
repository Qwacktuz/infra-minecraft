#!/bin/bash
set -e

# Ensure we are in the correct directory
cd "$HOME/app" || exit 1

echo "running rollback..."
echo "🔍 Searching for local pre-restore backups..."

# 1. Find the latest backup directory (sort reverse to get the newest timestamp)
# We look for folders matching the pattern create by the restore script
LATEST_BACKUP=$(ls -1d data/minecraft_pre_restore_* 2>/dev/null | sort -r | head -n 1)

if [ -z "$LATEST_BACKUP" ]; then
  echo "❌ No local backups found (data/minecraft_pre_restore_*)."
  echo "   Cannot rollback."
  exit 1
fi

echo ""
echo "⚠️  FOUND BACKUP: $LATEST_BACKUP"
echo "------------------------------------------------------------"
echo "This will:"
echo "  1. DELETE the current 'data/minecraft' folder (the broken restore)."
echo "  2. MOVE '$LATEST_BACKUP' back to 'data/minecraft'."
echo "  3. Restart the server."
echo "------------------------------------------------------------"
echo ""

read -r -p "🚨 Are you sure you want to ROLLBACK to this state? [y/N]: " confirm
if [[ ! $confirm =~ ^[yY] ]]; then
  echo "❌ Aborted."
  exit 0
fi

# 2. Stop the Server
echo "🛑 Stopping Minecraft Server..."
docker compose stop minecraft-service

# 3. Swap the folders
echo "🗑️  Removing broken data/minecraft folder..."
# We use sudo here just in case the failed restore left root-owned files
if [ -d "data/minecraft" ]; then
  sudo rm -rf data/minecraft
fi

echo "🔙 Restoring old data folder..."
mv "$LATEST_BACKUP" data/minecraft

# 4. Fix Permissions (Just in case)
echo "🔧 Ensuring permissions are correct..."
# Force ownership to internal uid 1000 (External 100999)
docker run --rm -v "$(pwd)/data/minecraft:/data" alpine chown -R 1000:1000 /data

# 5. Restart
echo "🚀 Starting Minecraft Server..."
docker compose up -d minecraft-service

echo "✅ Rollback Complete!"
echo "   Server restored to state before the last restore attempt."
echo "   Monitoring logs for 10 seconds..."
timeout 20s docker compose logs -f minecraft-service || true
