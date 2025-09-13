# 🚀 PostgreSQL Backup & Restore Tool

Shell script interaktif untuk melakukan backup dan restore database PostgreSQL **khusus struktur & data saja** (tanpa role dan privileges).  
Mendukung pilihan backup, restore, dan keluar aplikasi, lengkap dengan emoticon keren untuk pengalaman yang lebih menyenangkan!

---

✨ **Kredit:** Aleh [https://abdialeh.me] - © 2025

---

## Fitur

- 🗄️ **Backup:** Backup struktur & data database PostgreSQL (tanpa role/ACL/owner)
- ♻️ **Restore:** Restore ke server/nama database berbeda
- ❌ **Batal/Keluar:** Opsi keluar aplikasi
- 🚦 **Interaktif:** Input mudah, ada konfirmasi & notifikasi sukses/gagal
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

Masukkan data host, user, database, dan path file backup sesuai kebutuhan.

> **Catatan:**  
> - Untuk restore, database tujuan **harus sudah dibuat dan kosong** (gunakan `createdb` jika perlu).
> - Script ini tidak membackup/grant role & privileges.

## Contoh Backup

```
🗄️  Mode Backup
Host (default: localhost): 
Port (default: 5432): 
User (default: postgres): 
Nama Database: dbku
Path file backup (default: ./backup_YYYYmmdd_HHMMSS.sql): 
🔑 Password PostgreSQL untuk user postgres: ****
⏳ Membackup database...
✅ Backup selesai: ./backup_20250913_104526.sql
```

## Contoh Restore

```
♻️  Mode Restore
Host tujuan (default: localhost): 
Port tujuan (default: 5432): 
User tujuan (default: postgres): 
Nama Database tujuan: dbbaru
Path file backup (.sql): ./backup_20250913_104526.sql
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
