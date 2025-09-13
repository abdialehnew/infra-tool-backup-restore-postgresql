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
    read -p "Path file backup (default: ./backup_$(date +%Y%m%d_%H%M%S).sql): " BACKUP_PATH
    BACKUP_PATH=${BACKUP_PATH:-"./backup_$(date +%Y%m%d_%H%M%S).sql"}

    read -s -p "🔑 Password PostgreSQL untuk user $PGUSER: " PGPASSWORD
    echo

    export PGPASSWORD

    echo "⏳ Membackup database..."
    pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" \
        --no-owner --no-privileges --no-acl -F p -f "$BACKUP_PATH"
    unset PGPASSWORD

    if [[ $? -eq 0 ]]; then
        echo "✅ Backup selesai: $BACKUP_PATH"
    else
        echo "❌ Backup gagal!"
    fi

elif [[ "$MODE" == "2" ]]; then
    # RESTORE MODE
    echo "=== ♻️  Mode Restore ==="
    read -p "Host tujuan (default: localhost): " PGHOST
    PGHOST=${PGHOST:-localhost}
    read -p "Port tujuan (default: 5432): " PGPORT
    PGPORT=${PGPORT:-5432}
    read -p "User tujuan (default: postgres): " PGUSER
    PGUSER=${PGUSER:-postgres}
    read -p "Nama Database tujuan: " PGDATABASE
    read -p "Path file backup (.sql): " BACKUP_PATH

    read -s -p "🔑 Password PostgreSQL untuk user $PGUSER: " PGPASSWORD
    echo

    export PGPASSWORD

    # Pastikan database sudah ada
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
