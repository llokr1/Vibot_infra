#!/bin/bash
# PostgreSQL Primary DB에서 Replication 사용자 및 슬롯 생성 스크립트

set -e

echo "Setting up replication on primary database..."

# Replication 사용자 생성 (이미 존재하면 무시)
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'replicator') THEN
            CREATE USER replicator WITH REPLICATION PASSWORD '${POSTGRES_REPLICATION_PASSWORD}';
        END IF;
    END
    \$\$;
    
    -- Replication 슬롯 생성 (이미 존재하면 무시)
    SELECT pg_create_physical_replication_slot('backup_slot', true, false)
    WHERE NOT EXISTS (
        SELECT 1 FROM pg_replication_slots WHERE slot_name = 'backup_slot'
    );
EOSQL

echo "Replication setup completed"




