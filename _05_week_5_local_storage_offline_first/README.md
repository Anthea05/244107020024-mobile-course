# Laporan Praktikum 3: Cache-First dan Antrean Sync (Offline-First)
 
**Topik:** Local Storage & Offline-First Architecture (Minggu 5)  

---

Terdapat tiga fitur utama yang diimplementasikan:
1. **Cache-First Read untuk Data API (`/posts` JSONPlaceholder):**
   - Menampilkan data dari basis data lokal (tabel `cached_posts`) seketika saat aplikasi dibuka agar tampilan tidak kosong (*blank*) ketika perangkat sedang offline.
2. **Sinkronisasi Catatan Kotor (*Dirty Notes*):**
   - Setiap catatan baru atau perubahan yang dibuat secara lokal ditandai dengan flag status kotor (`dirty = 1`).
   - Fitur `syncNotes` menyimulasikan proses *batch upload* ke server dengan jeda waktu (`Duration(seconds: 1)`), kemudian menandai seluruh catatan menjadi bersih (`dirty = 0`) setelah simulasi berhasil.
3. **Simulasi Offline Deterministik (`forceOffline`):**
   - Fitur toggle switch pada UI untuk memutus interaksi jaringan secara terisolasi tanpa bergantung pada konektivitas fisik perangkat atau Wi-Fi kelas.

---
## 3. Langkah Observasi dan Hasil Pengujian

Seluruh hasil tangkapan layar pengujian disimpan di direktori `screenshots/`:

| Nomor | Nama File | Deskripsi Pengujian |
| :---: | :--- | :--- |
| **1** | `C:\Users\amodi\Videos\Semester 5\Pemrograman Mobile\244107020024-mobile-course\_05_week_5_local_storage_offline_first\screenshots\1.png` | Keadaan awal saat aplikasi dimuat pertama kali dan menginisialisasi basis data SQLite. |
| **2** | `C:\Users\amodi\Videos\Semester 5\Pemrograman Mobile\244107020024-mobile-course\_05_week_5_local_storage_offline_first\screenshots\2.png` | Switch `forceOffline` diaktifkan. Tombol sinkronisasi ditekan saat offline dan menampilkan pesan penolakan bahwa sinkronisasi tidak dapat berjalan. |
| **3** | `C:\Users\amodi\Videos\Semester 5\Pemrograman Mobile\244107020024-mobile-course\_05_week_5_local_storage_offline_first\screenshots\3.png` | Catatan baru ditambahkan saat offline. Sistem menandai catatan dengan chip **Dirty** dan *badge counter* pada ikon sinkronisasi bertambah secara deterministik. |
| **4** | `C:\Users\amodi\Videos\Semester 5\Pemrograman Mobile\244107020024-mobile-course\_05_week_5_local_storage_offline_first\screenshots\4.png` | Switch `forceOffline` dinonaktifkan kembali. Tombol sinkronisasi dijalankan, proses simulasi selesai, status catatan beralih ke **Synced**, dan *badge counter* kembali ke **0**. |
| **5** | `C:\Users\amodi\Videos\Semester 5\Pemrograman Mobile\244107020024-mobile-course\_05_week_5_local_storage_offline_first\screenshots\5.png` | No Issues Found saat pengecek an flutter analyze|

---

1. Mengapa daftar catatan tidak boleh disimpan di SharedPreferences? Apa yang rusak jika aturan ini dilanggar? 
SharedPreferences didesain untuk key-value store data primitif kecil (boolean, string, int). Data disimpan dalam satu file XML (Android) atau plist (iOS) yang dibaca seluruhnya ke dalam memori (in-memory map). 
konsekuensi pelanggaran: Tidak bisa melakukan sorting, Tidak memiliki transaksi atomik (ACID).
2. Kapan cache-first cukup, dan kapan Anda membutuhkan strategi lain (misalnya network-first)? 
Cache-First:Data yang jarang berubah (statis/semi-statis) atau toleran terhadap sedikit keterlambatan update (eventual consistency)
Network-First: Data yang menuntut akurasi mutlak dan bersifat real-time atau transaksional, misalnya harga saham/kripto, ketersediaan tiket bioskop/pesawat, saldo dompet digital, atau status pembayaran.
3. Bagaimana dirty flag berubah menjadi antrean sync tanpa memblokir UI? Kapan antrean terpisah (tabel outbox) menjadi perlu? 
Saat user membuat/mengedit catatan, data langsung di-commit ke SQLite dengan status dirty = 1. Operasi ini instan (<5 ms), sehingga UI langsung merender pembaruan tanpa menunggu respon network.

Proses syncNotes() dieksekusi secara asinkron di background menggunakan Future atau isolate terpisah.
- Kapan Tabel Outbox (Antrean Terpisah) Diperlukan: Ketika operasi tidak hanya berupa upsert data utuh, melainkan rangkaian mutasi granular yang memiliki urutan kronologis ketat (misal: INSERT, lalu UPDATE title, lalu DELETE).
4. Bagian mana dari rekomendasi AI yang Anda tolak, dan mengapa?
Penggunaan SharedPreferences untuk menampung cache postingan: Ditolak karena cache postingan JSONPlaceholder berjumlah puluhan hingga ratusan item yang lebih tepat dan aman dipelihara di tabel SQLite terpisah (cached_posts).