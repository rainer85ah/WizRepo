#!/bin/bash
set -euo pipefail

# Load persistent environment variables
[ -f /etc/profile.d/custom_env.sh ] && source /etc/profile.d/custom_env.sh

DATE=$(date +"%Y-%m-%d-%H-%M")
BACKUP_DIR="/tmp/mongodb"
BACKUP_FILE="${BACKUP_DIR}/backup_${DATE}.gz"
MONGO_URI="mongodb://${MONGO_ADMIN_USER}:${MONGO_ADMIN_PASS}@localhost:27017"

mkdir -p "$BACKUP_DIR"

echo "$(date) - Starting MongoDB backup..."
if /usr/bin/mongodump --uri="$MONGO_URI" --archive="$BACKUP_FILE" --gzip --oplog; then
    echo "$(date) - Backup created: $BACKUP_FILE"

    # Upload to S3 using IAM role
    if aws s3 cp "$BACKUP_FILE" "s3://${S3_BUCKET_NAME}/mongodb_backups/" --storage-class INTELLIGENT_TIERING; then
        echo "$(date) - Backup uploaded to S3: ${S3_BUCKET_NAME}"
    else
        echo "$(date) - ERROR: Failed to upload to S3."
        exit 1
    fi
else
    echo "$(date) - ERROR: MongoDB backup failed."
    exit 1
fi

rm -rf "$BACKUP_DIR"
echo "$(date) - Local backup removed."
