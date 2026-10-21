import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'services/fcm_service.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';

final appRouter = GoRouter(
 redirect: (context, state) {
    final container = ProviderScope.containerOf(context);
    final loggedIn = container.read(authStateProvider).value ?? false;
    final goingToLogin = state.matchedLocation == '/login';

    if (!loggedIn && !goingToLogin) return '/login';
    if (loggedIn && goingToLogin) return '/';
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginPage(),
    ),
    GoRoute(
      path: '/',
      builder: (_, __) => const HomePage(),
    ),
    GoRoute(
      path: '/pengumuman/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return Scaffold(
          appBar: AppBar(title: const Text('Pengumuman')),
          body: Center(child: Text('Detail pengumuman nomor $id')),
        );
      },
    ),
  ],
);
void goDebug(String route) {
  debugPrint('NAVIGASI KE: $route');
  appRouter.go(route);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  registerBackgroundHandler();
  runApp(const ProviderScope(child: CampusNotifyApp()));

  await initLocalNotifications(goDebug);
  listenForeground(goDebug);
  await handleTerminated(goDebug);
  initFcmToken(onToken: (token) async {
    debugPrint('FCM token: $token');
  }).catchError((e) {
    debugPrint('FCM init gagal: $e');
  });
}

class CampusNotifyApp extends ConsumerWidget {
  const CampusNotifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Campus Notify',
      theme: ThemeData(useMaterial3: true),
      routerConfig: appRouter,
    );
  }
}
