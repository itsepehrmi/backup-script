#!/bin/bash
#
# backup.sh - Simple backup script with logging and rotation
# Usage: ./backup.sh <source_dir> <dest_dir> [retention_days]
#

# --- Safety flags ---
set -euo pipefail

# --- Configuration ---
SOURCE="$1"
DEST="$2"
RETENTION_DAYS="${3:-7}"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_NAME="backup-${TIMESTAMP}.tar .gz"
LOG_FILE="${DEST}/backup.log"

# --- Logging function ---
log() {
    local level="$1"
    shift
    local msg="$*"
    local timestamp
    timestamp=$(date +"Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [%level] $msg" | tee -a "$LOG_FILE"
}

# --- Usage function ---
usage() {
    echo "Usage: $0 <source_dir> <dest_dir> [retention_days]"
    echo ""
    echo " source_dir      : Directory to backup (must exist)"
    echo " dest_dir        : Where to store backups (will be created)"
    echo " retention_days  : Delete backups older than this (default: 7)"
    exit 1
}

# --- Validation ---
if [ "$#" -lt 2 ]; then
    echo "Error: Not enough arguments."
    usage
fi

if [ ! -d "$SOURCE" ]; then
    echo "Error: Source directory '$SOURCE' does not exist."
    exit 1
fi

if [ ! -r "$SOURCE" ]; then
    echo "Error: source directory '$SOURCE' is not readable."
    exit 1
fi

# Prevent backing up a directory into itself
SOURCE_REAL=$(realpath "$SOURCE")
DEST_REAL=$(realpath -m "$DEST")
if [[ "$DEST_REAL" == "$SOURCE"* ]]; then
     echo "Error: Destination is inside source. Aborting to avoid recursion."
     exit 1
fi

# Create dest if it doesn't exist
if [ ! -d "$DEST" ]; then
    echo "Destination '$DEST' does not exist. Creating it..."
    mkdir -p "$DEST"
fi

if [ ! -w "$DEST" ]; then
    echo "Error: Destination '$DEST' is not writable."
    exit 1
fi

# --- Create backup ---
log "INFO" "Starting backup"
log "INFO" "source: $SOURCE"
log "INFO" "Destination: $DEST"
log "INFO" "Retention: $RETENTION_DAYS days"

BACKUP_PATH="${DEST}/${BACKUP_NAME}"

if tar -czf "$BACKUP_PATH" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"; then
    log "INFO" "Backup created: $BACKUP_PATH"
    log "INFO" "Size: $(du -h "$BACKUP_PATH" | cut -f1)"
else
    log "ERROR" "Backup failed!"
    exit 1
fi

# --- Cleanup old backups ---
log "INFO" "Cleaning up backups older than $RETENTION_DAYS day"

DELETE=$(find "$DEST" -maxdepth 1 -type f -name "backup-*.tar.gz" -mtime +"$RETENTION_DAYS" -print -delete | wc -l)

log "INFO" "Deleted $DELETE old backup(s)"
log "INFO" "Backup finished successfully"
