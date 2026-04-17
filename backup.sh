#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <server-address>"
  exit 1
fi

SERVER="$1"
REMOTE_APPS_DATA="~/docker-apps/apps-data"
REMOTE_PROJECT="~/docker-apps"
LOCAL_BACKUPS_DIR="$(dirname "$0")/backups"
DATETIME=$(date +"%Y%m%d_%H%M%S")
SERVER_NAME=$(echo "$SERVER" | sed 's/[^a-zA-Z0-9]/_/g')

mkdir -p "$LOCAL_BACKUPS_DIR"

echo "==> Getting list of app directories..."
APPS=$(ssh "$SERVER" "ls -d $REMOTE_APPS_DATA/*/  2>/dev/null | xargs -I{} basename {}")

if [ -z "$APPS" ]; then
  echo "No app directories found in $REMOTE_APPS_DATA"
  exit 0
fi

echo "==> Found apps: $(echo $APPS | tr '\n' ' ')"

REMOTE_TMP="/tmp/docker-apps-backup-$$"
ssh "$SERVER" "mkdir -p $REMOTE_TMP"

for APP in $APPS; do
  ARCHIVE="${SERVER_NAME}-${APP}-${DATETIME}.zip"
  echo ""
  echo "==> [$APP] Stopping container..."
  ssh "$SERVER" "cd $REMOTE_PROJECT && ./down.sh $APP"
  echo "==> [$APP] Creating zip archive..."
  ssh "$SERVER" "cd $REMOTE_APPS_DATA && zip -r $REMOTE_TMP/$ARCHIVE $APP/ -q"
  echo "==> [$APP] Starting container back..."
  ssh "$SERVER" "cd $REMOTE_PROJECT && ./up.sh $APP"
  echo "==> [$APP] Downloading archive..."
  scp "$SERVER:$REMOTE_TMP/$ARCHIVE" "$LOCAL_BACKUPS_DIR/$ARCHIVE"
  ssh "$SERVER" "rm -f $REMOTE_TMP/$ARCHIVE"
  echo "==> [$APP] Done."
done

ssh "$SERVER" "rm -rf $REMOTE_TMP"

echo ""
echo "Backup complete. Files saved to: $LOCAL_BACKUPS_DIR"
ls -lh "$LOCAL_BACKUPS_DIR/${SERVER_NAME}-"*"-${DATETIME}.zip" 2>/dev/null || true
