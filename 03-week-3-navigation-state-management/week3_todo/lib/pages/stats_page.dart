import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<List<String>> fetchStatsData({double? randomValue}) async {
  await Future.delayed(const Duration(seconds: 2));

  final nilaiAcak = randomValue ?? Random().nextDouble();
  final gagal = nilaiAcak < 0.3;

  if (gagal) {
    throw Exception('Gagal mengambil data statistik. Coba lagi.');
  }

  return const [
    'Total Pengguna Aktif: 1.240',
    'Pertandingan Hari Ini: 18',
    'Tingkat Kepuasan Pengguna: 92%',
  ];
}

class StatsNotifier extends AsyncNotifier<List<String>> {
  @override
  FutureOr<List<String>> build() async {
    return fetchStatsData();
  }

  Future<void> retry() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => fetchStatsData());
  }
}

final statsProvider = AsyncNotifierProvider<StatsNotifier, List<String>>(
  StatsNotifier.new,
  retry: (retryCount, error) => null,
);

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 12),
                Text(error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
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
