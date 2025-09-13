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

    echo "⏳ Mengambil daftar tabel..."
    TABLES=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -t -c "SELECT tablename FROM pg_tables WHERE schemaname='public';")
    TABLE_COUNT=$(echo "$TABLES" | grep -c .)
    if [[ $TABLE_COUNT -eq 0 ]]; then
        echo "❌ Tidak ada tabel di database $PGDATABASE!"
        unset PGPASSWORD
        exit 1
    fi

    echo "-- Backup struktur database" > "$BACKUP_PATH"
    echo "1/3 (5%) Membackup struktur database..."
    pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" --schema-only --no-owner --no-privileges --no-acl >> "$BACKUP_PATH"

    echo "-- Backup data per tabel" >> "$BACKUP_PATH"
    i=0
    for tbl in $TABLES; do
        i=$((i+1))
        percent=$(( (i*90/TABLE_COUNT) + 5 ))
        echo "$i/$TABLE_COUNT ($percent%) Membackup tabel: $tbl"
        pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" --data-only --table="$tbl" --no-owner --no-privileges --no-acl >> "$BACKUP_PATH"
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
