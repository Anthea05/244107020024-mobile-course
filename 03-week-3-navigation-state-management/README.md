# Week 3 — Navigation & State Management (ToDo App + Statistik)

## Tujuan

Membangun aplikasi ToDo dengan navigasi multi-halaman (GoRouter) dan
state management (Riverpod), sekaligus mensimulasikan pengambilan
data asinkron (AsyncValue) lengkap dengan penanganan loading, error,
dan success di UI.

## Fitur Utama

- **Daftar Tugas** — tambah, tandai selesai/belum, hapus tugas.
- **Filter Tugas** — tampilkan Semua / Belum Selesai / Selesai, lewat
  provider turunan (`filteredTodoListProvider`) yang membaca
  `todoListProvider`.
- **Halaman Detail Tugas** — tap satu tugas untuk melihat detail,
  bisa toggle status & hapus dari sana. Dibuka lewat `context.push`
  dan bisa diakses langsung lewat path `/todo/:id`.
- **Halaman Statistik** — mensimulasikan pengambilan data dari
  server (delay 2 detik, gagal ±30%), dengan UI yang menangani tiga
  kondisi: loading (spinner), error (pesan + tombol coba lagi), dan
  success (daftar statistik).
- **Navigasi bawah (NavigationBar)** — berpindah antara halaman
  Tugas dan Statistik tanpa kehilangan state masing-masing.

## Stack Teknologi

- Flutter
- [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) — state management (`Notifier`, `AsyncNotifier`, `Provider` turunan)
- [go_router](https://pub.dev/packages/go_router) — navigasi berbasis path/URL

## Struktur Folder

```
lib/
├── main.dart                  # entry point, ProviderScope + MaterialApp.router
├── router.dart                # definisi GoRouter + NavigationBar (AppShell)
├── pages/
│   ├── todo_page.dart         # daftar tugas
│   ├── todo_detail_page.dart  # detail satu tugas
│   └── stats_page.dart        # simulasi async + AsyncValue
├── providers/
│   └── todo_provider.dart     # Notifier untuk data, filter turunan
└── widgets/
    └── todo_tile.dart         # satu baris item tugas
test/
├── widget_test.dart           # test tambah tugas
├── navigation_test.dart       # test push ke detail & back
└── stats_test.dart            # unit test StatsNotifier (loading/error/success/retry)
docs/
└── README_AI_Challenge.md     # dokumentasi AI Challenge (prompt, output, perbaikan)
screenshots/
└── ...                        # tangkapan layar tiap fitur
```

## Cara Menjalankan

```bash
flutter pub get
flutter run
```

Untuk menjalankan test:

```bash
flutter test
```

Untuk verifikasi kualitas kode:

```bash
flutter analyze
```

## Hasil yang Dicapai

- Navigasi antar halaman bekerja lewat GoRouter: `context.go` untuk
  berpindah tab (Tugas ↔ Statistik) tanpa menumpuk riwayat, dan
  `context.push` untuk masuk ke halaman detail dengan tombol back
  otomatis. Path detail (`/todo/:id`) juga bisa diakses langsung.
- State ToDo (`todoListProvider`) tetap bertahan saat berpindah
  antara halaman Tugas dan Statistik, karena `ProviderScope`
  membungkus root aplikasi di `main.dart`, bukan per-halaman.
- Halaman Statistik menangani ketiga kondisi `AsyncValue` (loading,
  error, success) secara eksplisit lewat `.when()`, bukan cuma
  menampilkan hasil sukses.
- `flutter analyze` bersih tanpa issue, dan seluruh test di folder
  `test/` lulus.
- Proses menggunakan AI sebagai co-developer didokumentasikan penuh
  di `docs/README_AI_Challenge.md`, termasuk prompt yang dipakai,
  output awal AI, dan daftar perbaikan yang dilakukan beserta
  alasannya.