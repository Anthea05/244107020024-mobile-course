import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import '../local/db.dart';
import '../local/post.dart';

class PostRepository {
  final Future<Database> Function() _openDb;
  final Dio _dio;

  PostRepository({
    Future<Database> Function()? openDb,
    Dio? dio,
  })  : _openDb = openDb ?? openNotesDb,
        _dio = dio ?? Dio();

  // Baca data dari tabel cached_posts di SQLite
  Future<List<Post>> readCachedPosts() async {
    final db = await _openDb();
    final List<Map<String, dynamic>> maps = await db.query('cached_posts');
    return maps.map((e) => Post.fromJson(e)).toList();
  }

  // Simpan data hasil API ke tabel SQLite
  Future<void> savePostsToCache(List<Post> posts) async {
    final db = await _openDb();
    final batch = db.batch();
    for (var post in posts) {
      batch.insert(
        'cached_posts',
        post.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // Tarik data API di background
  Future<void> refreshPostsInBackground({Function()? onComplete}) async {
    try {
      final response = await _dio.get('https://jsonplaceholder.typicode.com/posts');
      if (response.statusCode == 200) {
        final List data = response.data;
        final posts = data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();

        await savePostsToCache(posts);

        if (onComplete != null) {
          onComplete();
        }
      }
    } catch (e) {
      // Diamkan error saat offline supaya aplikasi tidak crash
    }
  }

  // Method Cache-First sesuai instruksi modul
  Future<List<Post>> loadPostsCacheFirst({Function()? onRefreshDone}) async {
    final cached = await readCachedPosts();

    // Jalankan fetch background tanpa 'await' agar data cache langsung tampil
    refreshPostsInBackground(onComplete: onRefreshDone);

    return cached;
  }
}