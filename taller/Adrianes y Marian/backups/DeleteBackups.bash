#!/bin/bash

BACKUP_DIR="$(dirname "$0")/backups"

# find "$BACKUP_DIR" -type f -name "*.dumb" -mtime +2 -exec rm -v {} \;
find "$BACKUP_DIR" -type f -name "*.dump" \ -not -newermt '2 seconds ago' -exec rm -v {} \;
echo "Limpieza de backups completada: $(date)"