import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Tambahan import untuk secure storage
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Silakan login untuk menerima notifikasi',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Tambahkan async di sini
                // 1. Inisialisasi secure storage
                const storage = FlutterSecureStorage();

                // 2. Simpan token bohongan (mock) ke storage
                await storage.write(
                    key: 'access_token', value: 'jwt_token_polinema_12345');

                // 3. Baca kembali token dari storage untuk membuktikan sudah tersimpan
                final savedToken = await storage.read(key: 'access_token');

                // 4. Print ke console
                debugPrint('=========================================');
                debugPrint('🔒 BUKTI SECURE STORAGE: Token berhasil disimpan!');
                debugPrint('Kunci: access_token');
                debugPrint('Nilai: $savedToken');
                debugPrint('=========================================');

                // Lanjut simulasi login dan pindah halaman
                ref.read(authStateProvider.notifier).login();
                if (context.mounted) context.go('/');
              },
              child: const Text('Simulasi Login'),
            ),
          ],
        ),
      ),
    );
  }
}
