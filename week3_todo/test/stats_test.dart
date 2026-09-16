// ============================================================
// stats_page_test.dart
// Unit test untuk StatsNotifier & fetchStatsData.
//
// Cara jalanin: flutter test test/stats_page_test.dart
// (letakkan file ini di folder test/, sejajar dengan lib/)
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week3_todo/pages/stats_page.dart'; 

void main() {
  group('fetchStatsData (fungsi murni, tanpa provider)', () {
    test('mengembalikan 3 item statistik saat randomValue di atas 0.3 (sukses)', () async {
      // randomValue 0.9 dipaksa supaya tidak masuk kondisi gagal (< 0.3)
      final hasil = await fetchStatsData(randomValue: 0.9);

      expect(hasil, isA<List<String>>());
      expect(hasil.length, 3);
    });

    test('melempar Exception saat randomValue di bawah 0.3 (gagal)', () async {
      // randomValue 0.1 dipaksa supaya masuk kondisi gagal
      expect(
        () => fetchStatsData(randomValue: 0.1),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('StatsNotifier via ProviderContainer', () {
    test('state awal berubah dari loading -> data ketika berhasil', () async {
      final container = ProviderContainer(
        overrides: [
          // Kita override provider dengan notifier palsu (fake)
          // yang langsung mengembalikan data sukses, tanpa delay
          // 2 detik dan tanpa random asli. Ini praktik umum di
          // Riverpod supaya test cepat & deterministik.
          statsProvider.overrideWith(_FakeSuccessNotifier.new),
        ],
      );
      addTearDown(container.dispose);

      // Sebelum di-listen/di-read, provider belum jalan.
      // ref.read akan memicu build() pertama kali.
      final state = await container.read(statsProvider.future);

      expect(state, ['Data A', 'Data B', 'Data C']);
      expect(container.read(statsProvider), isA<AsyncData<List<String>>>());
    });

    test('state berubah menjadi AsyncError ketika fetch gagal', () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(_FakeErrorNotifier.new),
        ],
      );
      addTearDown(container.dispose);

      // Tunggu sampai build() selesai (akan throw di dalam).
      await container.read(statsProvider.future).catchError((_) => <String>[]);

      final state = container.read(statsProvider);
      expect(state, isA<AsyncError<List<String>>>());
    });

    test('retry() mengubah state error menjadi data ketika dipanggil ulang', () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(_FakeRetryNotifier.new),
        ],
      );
      addTearDown(container.dispose);

      // Percobaan pertama sengaja gagal.
      await container.read(statsProvider.future).catchError((_) => <String>[]);
      expect(container.read(statsProvider), isA<AsyncError<List<String>>>());

      // Panggil retry(), percobaan kedua sengaja sukses.
      await container.read(statsProvider.notifier).retry();

      final stateSetelahRetry = container.read(statsProvider);
      expect(stateSetelahRetry, isA<AsyncData<List<String>>>());
      expect(stateSetelahRetry.value, ['Data setelah retry']);
    });
  });
}

// ------------------------------------------------------------
// Fake notifier untuk kebutuhan testing.
// Meng-extend StatsNotifier supaya tetap kompatibel dengan tipe
// provider aslinya (AsyncNotifierProvider<StatsNotifier, ...>),
// tapi override build() supaya tidak menunggu delay 2 detik asli
// dan tidak bergantung pada angka random sungguhan.
// ------------------------------------------------------------

class _FakeSuccessNotifier extends StatsNotifier {
  @override
  Future<List<String>> build() async {
    return ['Data A', 'Data B', 'Data C'];
  }
}

class _FakeErrorNotifier extends StatsNotifier {
  @override
  Future<List<String>> build() async {
    throw Exception('Simulasi gagal untuk testing');
  }
}

class _FakeRetryNotifier extends StatsNotifier {
  @override
  Future<List<String>> build() async {
    throw Exception('Percobaan pertama gagal');
  }

  @override
  Future<void> retry() async {
    state = const AsyncValue.loading();
    state = const AsyncValue.data(['Data setelah retry']);
  }
}