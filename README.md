# 🚀 PostgreSQL Backup & Restore Tool

Shell script interaktif untuk melakukan backup dan restore database PostgreSQL **khusus struktur & data saja** (tanpa role dan privileges).

---

✨ **Kredit:** Aleh [https://abdialeh.me] - © 2025

---

## Fitur

- 🗄️ **Backup:** Backup struktur & data database PostgreSQL (tanpa role/ACL/owner)
- ♻️ **Restore:** Restore ke server/nama database berbeda
- 🚦 **Interaktif:** Input mudah, progres backup per-tabel dengan persentase, nama tabel yang sedang diproses, serta tahapan proses (struktur/data/finalisasi)
- 🏷️ **Multiple Schema:** Pilih satu atau lebih skema sekaligus saat backup
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

#### Pilihan Backup Skema Multiple

Setelah memasukkan info database, Anda akan melihat daftar skema yang tersedia, contoh:
```
Skema tersedia:
1) public
2) sales
3) hr
Masukkan nomor skema yang akan di-backup (pisahkan dengan koma, contoh: 1,3): 1,3
```
Script akan melakukan backup struktur dan seluruh tabel dari skema yang Anda pilih.

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
⏳ Mengambil daftar skema...
Skema tersedia:
1) public
2) sales
3) hr
Masukkan nomor skema yang akan di-backup (pisahkan dengan koma, contoh: 1,3): 1,3
📦 Skema terpilih: public hr
1/3 (5%) Membackup struktur database untuk skema: public hr...
1/8 (16%) Membackup tabel: public.users
2/8 (27%) Membackup tabel: public.orders
3/8 (38%) Membackup tabel: hr.employee
...
8/8 (95%) Membackup tabel: hr.salary
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