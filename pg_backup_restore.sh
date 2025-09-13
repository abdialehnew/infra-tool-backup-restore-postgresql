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

    echo "⏳ Mengambil daftar skema..."
    SCHEMAS=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -t -A -c "SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT IN ('pg_catalog','information_schema');")
    IFS=$'\n' read -rd '' -a SCHEMA_ARR <<<"$SCHEMAS"

    if [[ ${#SCHEMA_ARR[@]} -eq 0 ]]; then
        echo "❌ Tidak ada skema user di database!"
        unset PGPASSWORD
        exit 1
    fi

    echo "Skema tersedia:"
    echo "0) Semua skema"
    for idx in "">${SCHEMA_ARR[@]}"; do
        echo "$((idx+1))) ${SCHEMA_ARR[$idx]}"
    done

    read -p "Masukkan nomor skema yang akan di-backup (0 untuk semua, atau pisahkan dengan koma, contoh: 1,2): " SCHEMA_IDX

    # Ubah input menjadi array indeks
    SCHEMA_IDX=($(echo $SCHEMA_IDX | tr ',' ' '))

    # Jika user memilih 0, pilih semua skema
    if [[ " ${SCHEMA_IDX[@]} " =~ " 0 " ]]; then
        SELECTED_SCHEMAS=(${SCHEMA_ARR[@]})
    else
        SELECTED_SCHEMAS=()
        for i in "${SCHEMA_IDX[@]}"; do
            if [[ $i =~ ^[0-9]+$ ]] && (( i >= 1 && i <= ${#SCHEMA_ARR[@]} )); then
                idx=$((i-1))
                s=${SCHEMA_ARR[$idx]}
                if [[ -n "$s" ]]; then
                    SELECTED_SCHEMAS+=("$s")
                fi
            fi
        done
    fi

    if [[ ${#SELECTED_SCHEMAS[@]} -eq 0 ]]; then
        echo "❌ Tidak ada skema valid dipilih!"
        unset PGPASSWORD
        exit 1
    fi

    echo "📦 Skema terpilih: ${SELECTED_SCHEMAS[*]}"

    # Backup struktur database semua skema terpilih
    echo "-- Backup struktur database" > "$BACKUP_PATH"
    echo "1/3 (5%) Membackup struktur database untuk skema: ${SELECTED_SCHEMAS[*]}..."
    for s in "${SELECTED_SCHEMAS[@]}"; do
        pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" --schema-only --schema="$s" --no-owner --no-privileges --no-acl >> "$BACKUP_PATH"
    done

    # Backup data per tabel semua skema terpilih
    echo "-- Backup data per tabel" >> "$BACKUP_PATH"
    ALL_TABLES=()
    for s in "${SELECTED_SCHEMAS[@]}"; do
        TBL=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -t -A -c "SELECT tablename FROM pg_tables WHERE schemaname='$s';")
        for t in $TBL; do
            ALL_TABLES+=("$s.$t")
        done
    done

    TABLE_COUNT=${#ALL_TABLES[@]}
    if [[ $TABLE_COUNT -eq 0 ]]; then
        echo "❌ Tidak ada tabel di skema yang dipilih!"
        unset PGPASSWORD
        exit 1
    fi

    i=0
    for tbl in "${ALL_TABLES[@]}"; do
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
