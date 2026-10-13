# Laporan Praktikum: Networking REST API & Riverpod

## Hasil Pengujian Tiga Skenario Error

### 1. Skenario 1: Internet Normal
* **Langkah:** Jalankan aplikasi dengan koneksi internet aktif.
* **Hasil Pengamatan:**
  - Saat aplikasi pertama kali dibuka, widget menampilkan indikator loading (`CircularProgressIndicator`).
  - Setelah data berhasil di-fetch dari API `https://jsonplaceholder.typicode.com/posts`, UI langsung menampilkan daftar 100 data postingan menggunakan `ListView.builder`.
  - Masing-masing item menampilkan Avatar ID, judul (title), dan ringkasan isi (body).
* **Status:** Berhasil / Sesuai Ekspektasi.

---

### 2. Skenario 2: Simulasi Mode Pesawat (No Internet) & Refresh
* **Langkah:**
  1. Aktifkan Mode Pesawat (Airplane Mode) atau matikan Wi-Fi & Data Seluler.
  2. Tekan tombol refresh di pojok kanan atas `AppBar` atau tarik layar ke bawah (*pull-to-refresh*).
  3. Amati perubahan tampilan pada layar.
  4. Nyalakan kembali koneksi internet, lalu tekan tombol **"Coba lagi"**.
* **Hasil Pengamatan:**
  - Aplikasi menangkap error koneksi melalui `DioExceptionType.connectionError` atau `receiveTimeout`.
  - Fungsi `friendlyErrorMessage()` menerjemahkan exception teknis menjadi pesan yang mudah dipahami pengguna:
    > *"Tidak dapat terhubung ke server. Periksa internet Anda."* atau *"Koneksi lambat atau timeout. Periksa internet Anda lalu coba lagi."*
  - Di bawah pesan error muncul tombol **"Coba lagi"**.
  - Saat internet diaktifkan kembali dan tombol **"Coba lagi"** ditekan, fungsi `ref.invalidate(postListProvider)` dieksekusi, memicu proses loading ulang dan 100 post kembali berhasil dimuat.
* **Status:** Berhasil / Error handling ramah pengguna berfungsi normal.

---

### 3. Skenario 3: Simulasi Base URL Salah / Endpoint Rusak
* **Langkah:**
  1. Buka file `lib/data/api_client.dart`.
  2. Ubah `baseUrl` menjadi URL yang tidak valid/salah, contoh:
     ```dart
     baseUrl: 'https://jsonplaceholder-salah-alamat.typicode.com',
     ```
  3. Lakukan hot restart / jalankan aplikasi.
  4. Amati tampilan pada layar.
  5. Kembalikan `baseUrl` ke URL semula.
* **Hasil Pengamatan:**
  - Aplikasi gagal melakukan koneksi ke host (host lookup failure / connection error).
  - UI tidak mengalami *crash* atau *blank screen*, melainkan menampilkan penanganan error terpusat:
    > *"Tidak dapat terhubung ke server. Periksa internet Anda."*
  - Begitu URL dikembalikan ke `https://jsonplaceholder.typicode.com` dan tombol **"Coba lagi"** ditekan, aplikasi kembali memuat data post dengan normal.
* **Status:** Berhasil / Exception terisolasi dengan baik di layer Repository & Provider tanpa merusak aplikasi.
