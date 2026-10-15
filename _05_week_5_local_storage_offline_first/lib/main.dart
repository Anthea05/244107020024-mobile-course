import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/local/db.dart';
import 'data/local/note.dart';
import 'data/local/post.dart';
import 'data/repositories/note_repository.dart';
import 'data/sync.dart';
import 'presentation/pages/note_detail_page.dart';
import 'presentation/widgets/note_tile.dart';

final NoteRepository globalNoteRepo = NoteRepository();
final SyncService globalSyncService = SyncService(
  noteRepository: globalNoteRepo,
  openDb: openNotesDb,
);

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OfflineFirstHomePage(),
      routes: [
        GoRoute(
          path: 'note/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return NoteDetailPage(noteId: id, noteRepo: globalNoteRepo);
          },
        ),
      ],
    ),
  ],
);

// Notifier sederhana untuk tema gelap/terang (SharedPreferences)
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Baca preferensi tema yang tersimpan
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('is_dark_mode') ?? false;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp.router(
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
          title: 'Offline First App',
          themeMode: currentMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
        );
      },
    );
  }
}

class OfflineFirstHomePage extends StatefulWidget {
  const OfflineFirstHomePage({super.key});

  @override
  State<OfflineFirstHomePage> createState() => _OfflineFirstHomePageState();
}

class _OfflineFirstHomePageState extends State<OfflineFirstHomePage> {
  List<Note> _notes = [];
  List<Post> _posts = [];
  int _dirtyCount = 0;
  bool _forceOffline = false;
  bool _isLoading = false;
  String _lastOpened = '-';

  @override
  void initState() {
    super.initState();
    _initPreferencesAndData();
  }

  // Inisialisasi SharedPreferences & Data Lokal
  Future<void> _initPreferencesAndData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Baca waktu terakhir dibuka sebelumnya
    final savedTime = prefs.getString('last_opened_at');
    if (savedTime != null) {
      setState(() {
        _lastOpened = savedTime.substring(0, 19).replaceAll('T', ' ');
      });
    } else {
      setState(() {
        _lastOpened = 'Baru pertama kali dibuka';
      });
    }

    // Perbarui waktu buka sekarang ke SharedPreferences
    await prefs.setString('last_opened_at', DateTime.now().toIso8601String());

    // Muat data notes dan cached posts
    await _refreshAll();
  }

  Future<void> _refreshAll() async {
    await _loadNotes();
    await _loadPosts();
  }

  // 1. Muat Catatan Lokal & Hitung Status Dirty
  Future<void> _loadNotes() async {
    final notes = await globalNoteRepo.fetchNotes();
    final count = await globalNoteRepo.countDirty();
    if (mounted) {
      setState(() {
        _notes = notes;
        _dirtyCount = count;
      });
    }
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      if (_forceOffline) {
        final cached = await globalSyncService.readCachedPosts();
        if (mounted) setState(() => _posts = cached);
      } else {
        final cached = await globalSyncService.loadPostsCacheFirst(
          onBackgroundRefreshDone: () async {
            final updated = await globalSyncService.readCachedPosts();
            if (mounted) setState(() => _posts = updated);
          },
        );
        if (mounted) setState(() => _posts = cached);
      }
    } catch (e) {
      debugPrint('Error load posts: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. Tambah Catatan Baru
  Future<void> _addNote() async {
    final count = _notes.length + 1;
    await globalNoteRepo.addNote(
      title: 'Catatan #$count',
      body: 'Dibuat saat mode ${_forceOffline ? "Offline" : "Online"}',
    );
    await _loadNotes();
  }

  // 3. Sinkronisasi Catatan
  Future<void> _handleSync() async {
    if (_forceOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal sinkron: Mode forceOffline sedang aktif!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final syncedCount = await globalSyncService.syncNotes();
    await _loadNotes();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            syncedCount > 0
                ? 'Berhasil menyinkronkan $syncedCount catatan ke server.'
                : 'Semua catatan sudah bersih (0 dirty).',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Toggle Tema Terang / Gelap
  Future<void> _toggleTheme() async {
    final isDark = themeNotifier.value == ThemeMode.dark;
    themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', !isDark);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Praktikum 3: Offline First'),
        actions: [
          // Toggle Tema Gelap / Terang (SharedPreferences)
          IconButton(
            tooltip: isDark ? 'Mode Terang' : 'Mode Gelap',
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleTheme,
          ),
          // Toggle forceOffline
          Row(
            children: [
              Icon(
                _forceOffline ? Icons.cloud_off : Icons.cloud_done,
                color: _forceOffline ? Colors.orange : Colors.grey,
              ),
              Switch(
                value: _forceOffline,
                activeThumbColor: Colors.amber,
                onChanged: (val) {
                  setState(() => _forceOffline = val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 1),
                      content: Text(
                        val
                            ? 'Mode forceOffline: AKTIF'
                            : 'Mode forceOffline: NONAKTIF',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          // Tombol Sync & Badge Dirty
          Badge(
            label: Text('$_dirtyCount'),
            isLabelVisible: _dirtyCount > 0,
            alignment: const AlignmentDirectional(20, -1),
            child: IconButton(
              tooltip: 'Sync Catatan',
              icon: const Icon(Icons.sync),
              onPressed: _handleSync,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading && _notes.isEmpty && _posts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshAll,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  // Info Waktu Terakhir Dibuka (SharedPreferences)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Terakhir dibuka: $_lastOpened',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  // Daftar Catatan
                  Card(
                    color: isDark ? Colors.grey.shade900 : Colors.amber.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Daftar Catatan (Dirty: $_dirtyCount)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _addNote,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Tambah'),
                              ),
                            ],
                          ),
                          const Divider(),
                          if (_notes.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('Belum ada catatan lokal.'),
                            )
                          else
                            ..._notes.map(
                              (note) => NoteTile(
                                note: note,
                                onTap: () {
                                  if (note.id != null) {
                                    context.go('/note/${note.id}');
                                  }
                                },
                                onDelete: () async {
                                  if (note.id != null) {
                                    await globalNoteRepo.deleteNote(note.id!);
                                    await _loadNotes();
                                  }
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cached Posts (JSONPlaceholder)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (_posts.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          'Cache kosong. Matikan forceOffline lalu refresh.',
                        ),
                      ),
                    )
                  else
                    ..._posts.take(10).map(
                          (post) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(child: Text('${post.id}')),
                              title: Text(
                                post.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                post.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Muat Ulang',
        onPressed: _refreshAll,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}