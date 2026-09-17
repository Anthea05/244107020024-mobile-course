// ============================================================
// navigation_test.dart
// Widget test untuk memastikan navigasi GoRouter berfungsi:
// tap satu tugas -> masuk ke halaman detail -> tombol back -> balik lagi.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/main.dart';

void main() {
  testWidgets('tap todo membuka halaman detail, back kembali ke list', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Belajar GoRouter');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    expect(find.text('Belajar GoRouter'), findsOneWidget);

    await tester.tap(find.text('Belajar GoRouter'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Tugas'), findsOneWidget);
    expect(find.text('Status: Belum selesai'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('ToDo Riverpod'), findsOneWidget);
    expect(find.text('Belajar GoRouter'), findsOneWidget);
  });
}