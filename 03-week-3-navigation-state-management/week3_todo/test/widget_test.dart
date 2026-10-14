import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
// Kita import langsung halaman ToDo-nya
import 'package:week3_todo/pages/todo_page.dart';

void main() {
  testWidgets('menambah tugas baru', (tester) async {
    // 1. Bangun aplikasi tanpa GoRouter (Bypass navigasi)
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TodoPage(), // Langsung tembak ke halaman target!
        ),
      ),
    );

    // Karena GoRouter di-bypass, halamannya langsung instan muncul
    await tester.pumpAndSettle();

    // 2. Sekarang cek tulisan awal
    expect(find.text('Belum ada tugas'), findsOneWidget);

    // 3. Klik ikon tambah (sekarang pasti ketemu karena layarnya udah bener)
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // 4. Ketik teks
    await tester.enterText(find.byType(TextField), 'Kerjakan PR minggu 3');

    // 5. Simpan
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    // 6. Verifikasi berhasil
    expect(find.text('Kerjakan PR minggu 3'), findsOneWidget);
  });
}
