#!/bin/bash
set -e

echo "🔍 --- Restic Backup Tester ---"
echo "Checking connection to Cloudflare R2..."

# 1. List Snapshots
echo "Step 1: Listing available snapshots..."
docker compose run --rm --entrypoint restic backup -r rclone:r2:cactuz-mc-backups snapshots

# 2. Verify Integrity
echo ""
echo "Step 2: verifying data integrity (checking hashes)..."
docker compose run --rm --entrypoint restic backup -r rclone:r2:cactuz-mc-backups check
echo "✅ Integrity check passed."

# 3. Dry-Run Restore
echo ""
read -r -p "Do you want to perform a dry-run download test? (Downloads to temp folder) [y/N]: " confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
  TEST_DIR="./restore-test-$(date +%s)"
  mkdir -p "$TEST_DIR"

  echo "Step 3: Restoring 'latest' to $TEST_DIR ..."

  # Mount the test dir to /target inside the container
  docker compose run --rm \
    -v "$(pwd)/$TEST_DIR:/target" \
    --entrypoint restic \
    backup -r rclone:r2:cactuz-mc-backups restore latest --target /target

  echo "✅ Download complete."
  echo "Checking contents:"

  echo "Changing ownership to you..."
  echo "⚠️ Assuming hardcoded path ~/app/scripts exists"
  # FIXME: THIS PATH IS HARDCODED, BEWARE
  sudo chown -R "$(whoami):$(whoami)" ~/app/scripts
  ls -lh "$TEST_DIR/data"

  echo "Cleaning up test files..."
  rm -rf "$TEST_DIR"
  echo "✅ Cleanup complete. Test Passed."
else
  echo "Skipping download test."
fi
