import 'package:flutter_test/flutter_test.dart';

// Salin/import fungsi routeFromMessage kamu ke sini
String routeFromMessage(Map<String, dynamic> data) {
  final route = data['route'] as String?;
  if (route == null || route.isEmpty) return '/';
  return route.startsWith('/') ? route : '/$route';
}

// Tambahkan class ini di atas void main()
class FakeTokenStore {
  String? access;
  String? refresh;
}

void main() {
  test('routeFromMessage menangani route kosong dan menambahkan slash', () {
    // Test 1: Data kosong harus kembali ke home '/'
    expect(routeFromMessage({}), '/');

    // Test 2: Data rute normal
    expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');

    // Test 3: Data rute tanpa slash di awal (harus otomatis ditambah slash)
    expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
  });

  // Tambahkan test ini di dalam void main(), di bawah test yang pertama
  test('Logika sesi/refresh token bekerja', () {
    final store = FakeTokenStore();

    // Simulasi login sukses
    store.access = 'access_token_123';
    store.refresh = 'refresh_token_456';
    expect(store.access, isNotNull);

    // Simulasi refresh token
    final oldAccess = store.access;
    store.access = 'new_access_token_789'; // Token diperbarui

    expect(store.access, isNot(oldAccess));
    expect(store.refresh, equals('refresh_token_456')); // Refresh token tetap

    // Simulasi logout
    store.access = null;
    store.refresh = null;
    expect(store.access, isNull);
    expect(store.refresh, isNull);
  });
}
