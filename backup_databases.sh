#!/bin/sh

set pipefail

PGHOST=${PGHOST:-db.local}
PGPORT=${PGPORT:-5432}
PGUSER=${PGUSER:-postgres}
BACKUP_FOLDER=${BACKUP_FOLDER:-/backups}

if [ -z "${PGPASSWORD}" ]; then
    LOGIN_INFO="--username=${PGUSER} --no-password"
else
    LOGIN_INFO="--username=${PGUSER} --password"
fi

databases=$(psql -h ${PGHOST} -p ${PGPORT} ${LOGIN_INFO} -c "select datname from pg_database where not datistemplate and datallowconn and datname != 'postgres'" | tail -n +3 | head -n -2)

for db in $databases; do
    echo "Backing up $db"
    timestamp=$(date +%Y%m%d-%H%M%S%Z)
    directory="${BACKUP_FOLDER}/${db}"
    filename="${directory}/${db}.${timestamp}.dump"
    mkdir -p $directory
    pg_dump --host=${PGHOST} --port=${PGPORT} ${LOGIN_INFO} --format=c --no-privileges --no-owner --dbname=${db} --file=${filename}
    echo "Backup complete: $filename"
done
