import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

const double kWideBreakpoint = 700;

void main() => runApp(const DashboardApp());

class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: AcademicOverviewPage(
        isDark: isDark,
        onDarkChanged: (value) => setState(() => isDark = value),
      ),
    );
  }
}

class AcademicOverviewPage extends StatelessWidget {
  const AcademicOverviewPage({
    required this.isDark,
    required this.onDarkChanged,
    super.key,
  });

  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Academic Overview"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                const SizedBox(width: 4),
                Semantics(
                  label: isDark
                      ? "Mode gelap aktif, ketuk untuk beralih ke mode terang"
                      : "Mode terang aktif, ketuk untuk beralih ke mode gelap",
                  child: CupertinoSwitch(
                    value: isDark,
                    onChanged: onDarkChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= kWideBreakpoint;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _ProfileHeader(),
                const SizedBox(height: 20),
                _InfoCardGrid(isWide: isWide),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: "Profil mahasiswa Antehoo, jurusan Teknik Informatika",
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: theme.colorScheme.primary,
              child: Icon(
                Icons.person,
                size: 32,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Antehoo",
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "D4 Teknik Informatika · Polinema",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCardGrid extends StatelessWidget {
  const _InfoCardGrid({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    const cards = [
      _CardData(title: "Assignments", value: "8"),
      _CardData(title: "Attendance", value: "92%"),
      _CardData(title: "Portfolio", value: "Ready"),
      _CardData(title: "Current Week", value: "02"),
    ];

    if (!isWide) {
      // Layar sempit: 1 kolom
      return Column(
        children: [
          for (final card in cards) ...[
            _InfoCardTile(data: card),
            const SizedBox(height: 12),
          ],
        ],
      );
    }

    // Layar lebar: 2 kolom, dipasangkan per Row
    final rows = <Widget>[];
    for (var i = 0; i < cards.length; i += 2) {
      final hasSecond = i + 1 < cards.length;
      rows.add(
        Row(
          children: [
            Expanded(child: _InfoCardTile(data: cards[i])),
            const SizedBox(width: 12),
            Expanded(
              child: hasSecond
                  ? _InfoCardTile(data: cards[i + 1])
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
      rows.add(const SizedBox(height: 12));
    }
    return Column(children: rows);
  }
}

class _CardData {
  const _CardData({required this.title, required this.value});
  final String title;
  final String value;
}

class _InfoCardTile extends StatelessWidget {
  const _InfoCardTile({required this.data});
  final _CardData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: "${data.title}: ${data.value}",
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(data.title, style: theme.textTheme.titleMedium),
            ),
            Text(
              data.value,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
