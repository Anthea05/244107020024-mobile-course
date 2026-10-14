import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/todo_page.dart';
import 'pages/todo_detailpage.dart';
import 'pages/stats_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const TodoPage()),
        GoRoute(path: '/stats', builder: (context, state) => const StatsPage()),
      ],
    ),

    GoRoute(
      path: '/todo/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return TodoDetailPage(todoId: id);
      },
    ),
  ],
);

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = location.startsWith('/stats') ? 1 : 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
            case 1:
              context.go('/stats');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Todo'),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Statistik',
          ),
        ],
      ),
    );
  }
}
