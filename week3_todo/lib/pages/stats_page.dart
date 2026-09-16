// ============================================================
// stats_page.dart
// Halaman Flutter yang menampilkan data statistik dummy.
// Menggunakan flutter_riverpod dengan pola AsyncNotifierProvider
// (bukan StateProvider/StateNotifierProvider yang sudah usang).
// ============================================================

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ------------------------------------------------------------
// 0. FUNGSI SIMULASI FETCH (dipisah dari class notifier)
// ------------------------------------------------------------
// Sengaja dibuat sebagai fungsi top-level (bukan private method
// di dalam notifier) supaya bisa dipanggil dan diuji langsung
// dari file test, tanpa perlu membangun seluruh ProviderContainer
// dan tanpa bergantung pada keberuntungan angka acak.
//
// randomValue: nilai 0.0 - 1.0 yang menentukan gagal/tidaknya.
// Defaultnya pakai Random() sungguhan, tapi saat testing kita
// bisa suntik nilai tetap (misalnya selalu 0.1 -> selalu sukses,
// atau selalu 0.5 -> selalu gagal).
Future<List<String>> fetchStatsData({double? randomValue}) async {
  await Future.delayed(const Duration(seconds: 2));

  final nilaiAcak = randomValue ?? Random().nextDouble();
  final gagal = nilaiAcak < 0.3; // peluang 30%

  if (gagal) {
    throw Exception('Gagal mengambil data statistik. Coba lagi.');
  }

  // Data dummy, cuma 3 item sesuai requirement.
  return const [
    'Total Pengguna Aktif: 1.240',
    'Pertandingan Hari Ini: 18',
    'Tingkat Kepuasan Pengguna: 92%',
  ];
}

// ------------------------------------------------------------
// 1. NOTIFIER (otak dari state management)
// ------------------------------------------------------------
// AsyncNotifier itu class yang "menjaga" state berupa AsyncValue<T>.
// AsyncValue<T> otomatis punya 3 kemungkinan bentuk:
//   - AsyncLoading  -> lagi proses
//   - AsyncData     -> berhasil, ada datanya
//   - AsyncError    -> gagal, ada error-nya
// Kita TIDAK PERNAH mengubah state dengan cara mutasi langsung
// (misalnya state.add(...)). Setiap ganti state, kita bikin
// objek baru. Ini yang dimaksud "state immutable" di checklist.
class StatsNotifier extends AsyncNotifier<List<String>> {
  // build() dipanggil otomatis sekali saat provider pertama kali
  // di-watch. Riverpod otomatis membungkus hasil/exception dari
  // sini menjadi AsyncData atau AsyncError. Makanya kita bisa
  // langsung `return`/`throw` tanpa set state manual di sini.
  @override
  FutureOr<List<String>> build() async {
    return fetchStatsData();
  }

  // Dipanggil dari tombol "Coba Lagi" saat error.
  // ref.read dipakai di sini (bukan ref.watch) karena ini ada
  // di dalam callback/method, bukan di dalam build().
  Future<void> retry() async {
    // Set ke loading dulu secara eksplisit supaya spinner muncul
    // lagi saat user menekan tombol retry.
    state = const AsyncValue.loading();

    // AsyncValue.guard otomatis menangkap error dan mengubahnya
    // jadi AsyncError, tanpa perlu try-catch manual.
    // Ini juga cara "immutable": kita assign objek AsyncValue baru,
    // bukan mengubah isi state yang lama.
    state = await AsyncValue.guard(() => fetchStatsData());
  }
}

// ------------------------------------------------------------
// 2. PROVIDER
// ------------------------------------------------------------
// Provider dideklarasikan dengan tipe eksplisit
// AsyncNotifierProvider<StatsNotifier, List<String>>
// supaya jelas tipe notifier & tipe datanya, dan tidak duplikat
// dengan provider lain.
final statsProvider = AsyncNotifierProvider<StatsNotifier, List<String>>(
  StatsNotifier.new,
);

// ------------------------------------------------------------
// 3. UI (ConsumerWidget)
// ------------------------------------------------------------
// ConsumerWidget dipakai (bukan StatefulWidget + Consumer
// bertingkat) karena StatsPage tidak butuh state lokal sendiri,
// semua state datang dari provider.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch dipakai DI DALAM build() supaya widget ini
    // otomatis rebuild setiap kali state provider berubah.
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      // .when() memaksa kita menangani KETIGA kemungkinan state
      // (loading, error, data) sekaligus. Kalau salah satu
      // dilupakan, kode tidak akan compile. Ini menjawab poin
      // checklist "apakah ketiga state AsyncValue benar-benar
      // ditangani".
      body: statsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 12),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  // ref.read dipakai di callback (bukan ref.watch)
                  // karena kita cuma perlu MEMANGGIL method-nya,
                  // bukan mendengarkan perubahannya.
                  onPressed: () => ref.read(statsProvider.notifier).retry(),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (stats) => ListView.builder(
          itemCount: stats.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.bar_chart),
              title: Text(stats[index]),
            );
          },
        ),
      ),
    );
  }
}