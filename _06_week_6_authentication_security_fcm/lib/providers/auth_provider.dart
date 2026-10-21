import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthNotifier extends StateNotifier<AsyncValue<bool>> {
  // Status awal aplikasi adalah belum login (false)
  AuthNotifier() : super(const AsyncData(false));

  void login() {
    // Ubah status menjadi sudah login (true) saat fungsi dipanggil
    state = const AsyncData(true);
  }

  void logout() {
    state = const AsyncData(false);
  }
}

// Provider yang dibaca oleh go_router di main.dart
final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<bool>>((ref) {
  return AuthNotifier();
});