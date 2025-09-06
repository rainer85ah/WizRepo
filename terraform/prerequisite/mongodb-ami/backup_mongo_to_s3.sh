#!/bin/bash

# S3_BUCKET_NAME should be set in the cron job or IAM role
# No need to set AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY if using an IAM role

# Get the current date for the backup filename
DATE=$(date +"%Y-%m-%d-%H-%M")
BACKUP_DIR="/tmp/mongodb"
BACKUP_FILE="${BACKUP_DIR}/backup_${DATE}.gz"
mkdir -p "$BACKUP_DIR"

# Perform the MongoDB logical backup using mongodump.
# The --oplog flag ensures point-in-time consistency for replica sets.
/usr/bin/mongodump --uri="mongodb://mongodb_admin:pass123@localhost:27017" --archive="$BACKUP_FILE" --gzip --oplog

# Check if the backup was successful
if [ $? -eq 0 ]; then
    echo "MongoDB backup created successfully: $BACKUP_FILE"

    # Upload the backup to S3, using the automatically assigned IAM role credentials.
    # The --storage-class INTELLIGENT_TIERING is a good choice for backup data
    aws s3 cp "$BACKUP_FILE" "s3://${S3_BUCKET_NAME}/mongodb_backups/" --storage-class INTELLIGENT_TIERING

    if [ $? -eq 0 ]; then
        echo "Backup successfully uploaded to S3 bucket ${S3_BUCKET_NAME}"
    else
        echo "Error: Failed to upload backup to S3."
        exit 1
    fi
else
    echo "Error: Failed to create MongoDB dump."
    exit 1
fi

# Clean up local backup files to conserve disk space
rm -rf "$BACKUP_DIR"
