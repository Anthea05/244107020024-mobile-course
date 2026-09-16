import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week3_todo/pages/stats_page.dart';

void main() {
  testWidgets('StatsPage menampilkan loading spinner di awal', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: StatsPage())),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
  });
}
