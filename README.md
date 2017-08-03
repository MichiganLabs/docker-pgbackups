# Docker PG-Backups
### A Docker container to back up Postgres databases automatically

The `backup_databases.sh` script queries the database for all non-template databases and uses `pg_dump` to save them:

```sql
select datname from pg_database 
where 
  not datistemplate 
  and datallowconn 
  and datname != 'postgres';
```

An example `docker-compose.yml`:

```yaml
version: '2'
volumes:
  postgres:
  postgres-backups:
services:
  postgres:
    image: postgres:9.6.3-alpine
    volumes:
      - postgres:/var/lib/postgresql/data
  pgbackup:
    restart: always
    container_name: pgbackup
    image: michiganlabs:pgbackups
    volumes:
      - postgres-backups:/backups
    links:
      - postgres:db.local
    depends_on:
      - postgres
    environment:
      - PGHOST=db.local
      - PGPASSWORD=example
```