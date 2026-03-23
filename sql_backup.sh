#! /bin/bash

DATE=$(date -I)
LIST_CMD=$(mysql -sN -e "select schema_name from information_schema.SCHEMATA where schema_name like 'voip%';")
OLD_DIRS=$(find /srv/sql_backups -maxdepth 1 -type d -mtime +30)
LOG=/var/log/sql_backup.log

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG
}

mkdir -p /srv/sql_backups/$DATE

log "Starting backup | $DATE"

for DB in $LIST_CMD; do
    log "Backup: $DB"
    mysqldump --single-transaction $DB > /srv/sql_backups/$DATE/$DB.sql 2>> $LOG
    if [ $? -ne 0 ]; then
        log "ERROR: failed to backup $DB"
    else
        log "OK: $DB"
    fi
done


if [ -z "$OLD_DIRS" ]; then
    log "No backups to delete."
else
    for DIR in $OLD_DIRS; do
        log "Deleted old backups: $DIR"
        rm -rf $DIR 2>> $LOG
        if [ $? -ne 0 ]; then
            log "ERROR: failed to delete $DIR"
        else
            log "OK: $DIR"
        fi
    done
fi

log "Backup done | $DATE"