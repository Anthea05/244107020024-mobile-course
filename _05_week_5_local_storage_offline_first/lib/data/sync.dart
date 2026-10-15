import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import 'local/post.dart';
import 'repositories/note_repository.dart';

class SyncService {
  final NoteRepository noteRepository;
  final Future<Database> Function() openDb;
  final Dio dio;

  SyncService({required this.noteRepository, required this.openDb, Dio? dio})
    : dio = dio ?? Dio();

  Future<int> syncNotes() async {
    final dirtyCount = await noteRepository.countDirty();
    if (dirtyCount == 0) return 0;

    await Future.delayed(const Duration(seconds: 1));
    await noteRepository.markAllSynced();
    return dirtyCount;
  }

  Future<List<Post>> readCachedPosts() async {
    final db = await openDb();
    final List<Map<String, dynamic>> maps = await db.query('cached_posts');
    return maps.map(Post.fromJson).toList();
  }

  Future<List<Post>> loadPostsCacheFirst({
    Function()? onBackgroundRefreshDone,
  }) async {
    final cached = await readCachedPosts();
    _refreshPostsInBackground(onComplete: onBackgroundRefreshDone);
    return cached;
  }

  Future<void> _refreshPostsInBackground({Function()? onComplete}) async {
    try {
      final response = await dio.get(
        'https://jsonplaceholder.typicode.com/posts',
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        final posts = data
            .map((e) => Post.fromJson(e as Map<String, dynamic>))
            .toList();

        final db = await openDb();
        final batch = db.batch();
        for (var post in posts) {
          batch.insert(
            'cached_posts',
            post.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);

        if (onComplete != null) onComplete();
      }
    } catch (_) {}
  }
}
