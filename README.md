# 🚀 PostgreSQL Backup & Restore Tool

Shell script interaktif untuk melakukan backup dan restore database PostgreSQL **khusus struktur & data saja** (tanpa role dan privileges).

---

✨ **Kredit:** Aleh [https://abdialeh.me] - © 2025

---

## Fitur

- 🗄️ **Backup:** Backup struktur & data database PostgreSQL (tanpa role/ACL/owner)
- ♻️ **Restore:** Restore ke server/nama database berbeda
- 🚦 **Interaktif:** Input mudah, progres backup per-tabel dengan persentase, nama tabel yang sedang diproses, serta tahapan proses (struktur/data/finalisasi)
- ❌ **Batal/Keluar:** Opsi keluar aplikasi
- 🎉 **Emoticon:** Lebih fun dan informatif

## Cara Pakai

### 1. Download script

Simpan file `pg_backup_restore.sh` di komputer Anda dan beri izin eksekusi:

```sh
chmod +x pg_backup_restore.sh
```

### 2. Jalankan script

```sh
./pg_backup_restore.sh
```

### 3. Ikuti petunjuk di layar

Pilih menu:
- **1** untuk Backup
- **2** untuk Restore
- **3** untuk keluar

Masukkan data host, user, database, dan path folder backup sesuai kebutuhan.

> **Catatan:**  
> - Untuk restore, database tujuan **harus sudah dibuat dan kosong** (gunakan `createdb` jika perlu).
> - Script ini tidak membackup/grant role & privileges.

## Contoh Progress Backup

```
🗄️  Mode Backup
Host (default: localhost): 
Port (default: 5432): 
User (default: postgres): 
Nama Database: dbku
Path folder tujuan backup (default: ./backup): 
🔑 Password PostgreSQL untuk user postgres: ****
⏳ Mengambil daftar tabel...
1/3 (5%) Membackup struktur database...
1/10 (14%) Membackup tabel: users
2/10 (23%) Membackup tabel: orders
...
10/10 (95%) Membackup tabel: logs
100% (3/3) Finalisasi backup...
✅ Backup selesai: ./backup/backup_dbku_20250913_1115.bak
```

## Contoh Restore

```
♻️  Mode Restore
Host tujuan (default: localhost): 
Port tujuan (default: 5432): 
User tujuan (default: postgres): 
Nama Database tujuan: dbbaru
Path file backup (.bak/.sql): ./backup/backup_dbku_20250913_1115.bak
🔑 Password PostgreSQL untuk user postgres: ****
⚠️  Pastikan database tujuan (dbbaru) sudah dibuat dan kosong!
⏳ Melakukan restore database...
✅ Restore selesai ke database dbbaru di server localhost
```

## Lisensi

Bebas digunakan untuk keperluan pribadi maupun komersial.  
Tetap sertakan kredit ke Aleh [https://abdialeh.me] jika membagikan atau memodifikasi.

---

👨‍💻 **Selamat backup & restore PostgreSQL dengan gaya!** 🚀
