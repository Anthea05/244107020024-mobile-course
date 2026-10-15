import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const ProviderScope(child: CampusNotifyApp()));
}

class CampusNotifyApp extends ConsumerWidget {
  const CampusNotifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      redirect: (context, state) {
        final loggedIn = ref.watch(authStateProvider).value ?? false;
        final goingToLogin = state.matchedLocation == '/login';

        if (!loggedIn && !goingToLogin) return '/login';
        if (loggedIn && goingToLogin) return '/';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (_, _) => const LoginPage(),
        ),
        GoRoute(
          path: '/',
          builder: (_, _) => const HomePage(),
        ),
        GoRoute(
          path: '/pengumuman/:id',
          builder: (_, state) => AnnouncementPage(
            id: state.pathParameters['id'] ?? '',
          ),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Campus Notify',
      theme: ThemeData(useMaterial3: true),
      routerConfig: router,
    );
  }
}