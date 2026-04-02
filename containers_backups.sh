#!/bin/bash
set -e

DATE=$(date -I)
MAINPATH=/nfs/containers
BCKPPATH=/nfs/containers_backups/containers_$DATE
LOG=/var/log/containers_bckp.log

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG
}

error_exit() {
    log "ERROR: $1"
    exit 1
}

log "Starting backup | $DATE"

# Copy
log "Copying..."
rsync -a --info=progress2 $MAINPATH $BCKPPATH || error_exit "Failed to copy!"
log "Copying is complete."

# Archive
log "Archiving..."
tar -c $BCKPPATH | pv | gzip > $BCKPPATH.tar.gz || error_exit "Failed to archive!"
rm -rf $BCKPPATH
log "Archiving is complete."

log "Backup is READY | $DATE"