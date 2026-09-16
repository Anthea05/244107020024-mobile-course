# Week 3 - ToDo App & Async State Management

## Dokumentasi Hasil Praktikum

### 1. Tampilan Awal 
![Screenshot 1](doc/1.png)

### 2. Dialog Tambah Tugas Baru
![Screenshot 2](doc/2.png)

### 3. Tampilan Halaman Statistik
![Screenshot 3](doc/3.png)

### 4. Tampilan Halaman Statistik
![Screenshot 4](doc/4.png)

# AI Challenge — Dokumentasi

## 1. Prompt yang Digunakan
Buatkan halaman Flutter bernama StatsPage menggunakan flutter_riverpod.
Requirements:
- ConsumerWidget dengan satu AsyncNotifierProvider yang mensimulasikan
  pengambilan data statistik (delay 2 detik, kadang gagal 30%).
- UI harus menangani loading (spinner), error (pesan + tombol retry),
  dan success (ListView 3 item).
- Berikan unit test untuk notifier-nya.
- Jelaskan setiap bagian kode dalam komentar.
- Tambahan: pisahkan logika simulasi fetch (delay + peluang gagal)
  menjadi fungsi top-level yang menerima parameter opsional
  randomValue, supaya bisa diuji secara deterministik tanpa
  bergantung pada angka acak sungguhan.

**Struktur Unit Test:**
*   **Awalnya:** Unit test-nya mwncoba memanggil provider asli berkali-kali terus berharap mendapat kondisi gagal/berhasil.
*   **Masalahnya:** Jadinya *flaky*, waktu test-nya jadi lama, dan hasilnya nggak konsisten.
*   **Perbaikannya:** memakai `provider.overrideWith(...)` dengan *fake notifier* buat misahin test dari efek samping seperti *delay* dan *random*.

**Cek Manual:**
*   Memastikan `ref.watch` hanya ditaruh di dalam `build() untuk otomatis *rebuild* layarnya.
*   Memastikan `ref.read` hanya dipakai saat *callback* tombol *retry*, sesuai aturan dari modul.
*   Memastikan nggak ada yang mengubah state secara langsung (misal pakai `state.add()`), semua update state pakai penugasan baru (`state = ...`).

## 2. Dokumentasi Hasil AI Challange
| :--- | :---: | :--- |
| ![Screenshot 5](doc/5.png) || ![Screenshot 6](doc/6.png) |
| :--- | :---: | :--- |

### 3. Hasil Verifikasi Checklist

| Pertanyaan Checklist | Status | Keterangan |
| :--- | :---: | :--- |
| State diubah secara *immutable*? | ✅ | memakai `state = AsyncValue...`, tidak terjadi mutasi list langsung. |
| `ref.watch` cuma di `build()`, `ref.read` di *callback*? | ✅ | benar |
| Ketiga state `AsyncValue` ditangani? | ✅ | pakai `.when()`|
| Provider tipe eksplisit & tidak duplikat? | ✅ | memakai `AsyncNotifierProvider<StatsNotifier, List<String>>`. |
| Pakai API Riverpod modern? | ✅ | memakai `AsyncNotifier` + `ConsumerWidget` (nggak pakai *StateNotifier* yang jadul). |
| Lolos `flutter analyze` & `flutter test`? | ✅ | di-run tidak ada *warning*.  |

