import 'package:flutter/material.dart';
import 'data/local/note.dart';
import 'data/repositories/note_repository.dart';
import 'data/repositories/PostRepository.dart';
import 'data/local/post.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Offline First App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const OfflineFirstHomePage(),
    );
  }
}

class OfflineFirstHomePage extends StatefulWidget {
  const OfflineFirstHomePage({super.key});

  @override
  State<OfflineFirstHomePage> createState() => _OfflineFirstHomePageState();
}

class _OfflineFirstHomePageState extends State<OfflineFirstHomePage> {
  final NoteRepository _noteRepo = NoteRepository();
  final PostRepository _postRepo = PostRepository();

  List<Note> _notes = [];
  List<Post> _posts = [];
  int _dirtyCount = 0;
  bool _forceOffline = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  Future<void> _refreshAll() async {
    await _loadNotes();
    await _loadPosts();
  }

  // Muat data Catatan Lokal & Hitung Status Dirty
  Future<void> _loadNotes() async {
    final notes = await _noteRepo.fetchNotes();
    final count = await _noteRepo.countDirty();
    if (mounted) {
      setState(() {
        _notes = notes;
        _dirtyCount = count;
      });
    }
  }

  // Muat Cache-First Post
  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      if (_forceOffline) {
        // Simulasi Offline: hanya ambil data dari SQLite cache
        final cached = await _postRepo.readCachedPosts();
        if (mounted) setState(() => _posts = cached);
      } else {
        // Mode Online: ambil cache seketika, background update
        final cached = await _postRepo.loadPostsCacheFirst(
          onRefreshDone: () async {
            final updated = await _postRepo.readCachedPosts();
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

  // Tambah Catatan Baru (Secara default berstatus Dirty = 1)
  Future<void> _addNote() async {
    final count = _notes.length + 1;
    await _noteRepo.addNote(
      title: 'Catatan #$count',
      body: 'Dibuat saat mode ${_forceOffline ? "Offline" : "Online"}',
    );
    await _loadNotes();
  }

  // Sinkronisasi Catatan
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

    final syncedCount = await _noteRepo.syncNotes();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Praktikum 3: Offline First'),
        actions: [
          // 1. Toggle forceOffline
          Row(
            children: [
              Icon(
                _forceOffline ? Icons.cloud_off : Icons.cloud_done,
                color: _forceOffline ? Colors.orange : Colors.white,
              ),
              Switch(
                value: _forceOffline,
                activeColor: Colors.amber,
                onChanged: (val) {
                  setState(() => _forceOffline = val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 1),
                      content: Text(val ? 'Mode forceOffline: AKTIF' : 'Mode forceOffline: NONAKTIF'),
                    ),
                  );
                },
              ),
            ],
          ),

          // 2. Tombol Sync beserta Badge Dirty
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
                  // --- SEKSI CATATAN (NOTES & DIRTY STATUS) ---
                  Card(
                    color: Colors.amber.shade50,
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
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                            const Text('Belum ada catatan lokal.')
                          else
                            ..._notes.map(
                              (note) => ListTile(
                                dense: true,
                                title: Text(note.title),
                                subtitle: Text(note.body),
                                trailing: Chip(
                                  label: Text(
                                    note.dirty ? 'Dirty' : 'Synced',
                                    style: TextStyle(
                                      color: note.dirty ? Colors.deepOrange : Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  backgroundColor: note.dirty ? Colors.orange.shade100 : Colors.green.shade100,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- SEKSI POST CACHE-FIRST ---
                  const Text(
                    'Cached Posts (JSONPlaceholder)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),

                  if (_posts.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text('Cache kosong. Matikan forceOffline lalu tarik untuk refresh.'),
                      ),
                    )
                  else
                    ..._posts.take(10).map(
                          (post) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(child: Text('${post.id}')),
                              title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
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