#!/bin/bash
#
# 🚀 PostgreSQL Backup & Restore Tool 🚀
# Struktur & data saja (tanpa role dan privileges)
# ✨ Nama Kredit: Aleh [https://abdialeh.me] - © $(date +%Y) ✨
#

echo "🚀 PostgreSQL Backup & Restore Tool 🚀"
echo "--------------------------------------"
echo "✨ Nama Kredit: Aleh [https://abdialeh.me] - © $(date +%Y) ✨"
echo "--------------------------------------"
echo "Pilih mode:"
echo "1) 🗄️  Backup"
echo "2) ♻️  Restore"
echo "3) ❌ Batal / Keluar"
read -p "Masukkan pilihan (1/2/3): " MODE

if [[ "$MODE" == "1" ]]; then
    # BACKUP MODE
    echo "=== 🗄️  Mode Backup ==="
    read -p "Host (default: localhost): " PGHOST
    PGHOST=${PGHOST:-localhost}
    read -p "Port (default: 5432): " PGPORT
    PGPORT=${PGPORT:-5432}
    read -p "User (default: postgres): " PGUSER
    PGUSER=${PGUSER:-postgres}
    read -p "Nama Database: " PGDATABASE
    read -p "Path folder tujuan backup (default: ./backup): " BACKUP_DIR
    BACKUP_DIR=${BACKUP_DIR:-"./backup"}

    mkdir -p "$BACKUP_DIR"
    BACKUP_FILENAME="backup_${PGDATABASE}_$(date +%Y%m%d_%H%M).bak"
    BACKUP_PATH="${BACKUP_DIR%/}/$BACKUP_FILENAME"

    read -s -p "🔑 Password PostgreSQL untuk user $PGUSER: " PGPASSWORD
    echo

    export PGPASSWORD

    echo "⏳ Mengambil daftar schema..."
    SCHEMAS=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -t -c "SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT IN ('pg_catalog', 'information_schema') ORDER BY schema_name;")
    SCHEMA_COUNT=$(echo "$SCHEMAS" | grep -c .)
    if [[ $SCHEMA_COUNT -eq 0 ]]; then
        echo "❌ Tidak ada schema yang tersedia di database $PGDATABASE!"
        unset PGPASSWORD
        exit 1
    fi

    echo "📋 Daftar schema yang tersedia:"
    i=1
    declare -a SCHEMA_ARRAY
    for schema in $SCHEMAS; do
        echo "$i) $schema"
        SCHEMA_ARRAY[$i]="$schema"
        i=$((i+1))
    done

    read -p "Pilih schema (masukkan nomor dipisah koma, misal 1,2,4): " SCHEMA_SELECTION
    
    # Parse schema selection
    SELECTED_SCHEMAS=""
    IFS=',' read -ra SCHEMA_NUMS <<< "$SCHEMA_SELECTION"
    for num in "${SCHEMA_NUMS[@]}"; do
        num=$(echo "$num" | tr -d ' ')  # Remove spaces
        if [[ "$num" -gt 0 && "$num" -le ${#SCHEMA_ARRAY[@]} ]]; then
            if [[ -n "$SELECTED_SCHEMAS" ]]; then
                SELECTED_SCHEMAS="$SELECTED_SCHEMAS,'${SCHEMA_ARRAY[$num]}'"
            else
                SELECTED_SCHEMAS="'${SCHEMA_ARRAY[$num]}'"
            fi
        fi
    done

    if [[ -z "$SELECTED_SCHEMAS" ]]; then
        echo "❌ Tidak ada schema yang valid dipilih!"
        unset PGPASSWORD
        exit 1
    fi

    echo "✅ Schema terpilih: $(echo "$SELECTED_SCHEMAS" | tr "'" " " | tr "," " ")"
    
    echo "⏳ Mengambil daftar tabel dari schema terpilih..."
    TABLES_WITH_SCHEMA=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -t -c "SELECT schemaname || '.' || tablename FROM pg_tables WHERE schemaname IN ($SELECTED_SCHEMAS);")
    TABLE_COUNT=$(echo "$TABLES_WITH_SCHEMA" | grep -c .)
    if [[ $TABLE_COUNT -eq 0 ]]; then
        echo "❌ Tidak ada tabel di schema yang dipilih!"
        unset PGPASSWORD
        exit 1
    fi

    echo "-- Backup struktur database untuk schema terpilih" > "$BACKUP_PATH"
    echo "1/3 (5%) Membackup struktur database untuk schema terpilih..."
    # Build schema list for pg_dump --schema parameters
    SCHEMA_PARAMS=""
    IFS=',' read -ra SCHEMA_LIST <<< "$SCHEMA_SELECTION"
    for num in "${SCHEMA_LIST[@]}"; do
        num=$(echo "$num" | tr -d ' ')
        if [[ "$num" -gt 0 && "$num" -le ${#SCHEMA_ARRAY[@]} ]]; then
            SCHEMA_PARAMS="$SCHEMA_PARAMS --schema=${SCHEMA_ARRAY[$num]}"
        fi
    done
    # Execute pg_dump with schema parameters using eval to handle multiple arguments
    eval "pg_dump -h \"$PGHOST\" -p \"$PGPORT\" -U \"$PGUSER\" -d \"$PGDATABASE\" $SCHEMA_PARAMS --schema-only --no-owner --no-privileges --no-acl" >> "$BACKUP_PATH"

    echo "-- Backup data per tabel" >> "$BACKUP_PATH"
    i=0
    for schema_table in $TABLES_WITH_SCHEMA; do
        i=$((i+1))
        percent=$(( (i*90/TABLE_COUNT) + 5 ))
        echo "$i/$TABLE_COUNT ($percent%) Membackup tabel: $schema_table"
        pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" --data-only --table="$schema_table" --no-owner --no-privileges --no-acl >> "$BACKUP_PATH"
    done

    echo "100% (3/3) Finalisasi backup..."
    unset PGPASSWORD

    if [[ $? -eq 0 ]]; then
        echo "✅ Backup selesai: $BACKUP_PATH"
    else
        echo "❌ Backup gagal!"
    fi

elif [[ "$MODE" == "2" ]]; then
    # RESTORE MODE (belum ada progress detail)
    echo "=== ♻️  Mode Restore ==="
    read -p "Host tujuan (default: localhost): " PGHOST
    PGHOST=${PGHOST:-localhost}
    read -p "Port tujuan (default: 5432): " PGPORT
    PGPORT=${PGPORT:-5432}
    read -p "User tujuan (default: postgres): " PGUSER
    PGUSER=${PGUSER:-postgres}
    read -p "Nama Database tujuan: " PGDATABASE
    read -p "Path file backup (.bak/.sql): " BACKUP_PATH

    read -s -p "🔑 Password PostgreSQL untuk user $PGUSER: " PGPASSWORD
    echo

    export PGPASSWORD

    echo "⚠️  Pastikan database tujuan ($PGDATABASE) sudah dibuat dan kosong!"
    echo "⏳ Melakukan restore database..."

    psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -f "$BACKUP_PATH"

    unset PGPASSWORD

    if [[ $? -eq 0 ]]; then
        echo "✅ Restore selesai ke database $PGDATABASE di server $PGHOST"
    else
        echo "❌ Restore gagal!"
    fi

elif [[ "$MODE" == "3" ]]; then
    echo "👋 Aplikasi dibatalkan. Sampai jumpa lagi!"
    exit 0

else
    echo "🤔 Pilihan tidak valid! Keluar."
    exit 1
fi
