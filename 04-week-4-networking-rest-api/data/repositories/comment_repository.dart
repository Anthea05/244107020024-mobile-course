import 'package:dio/dio.dart';
import '../models/comment.dart';

/// Repository untuk resource comments pada JSONPlaceholder
class CommentRepository {
  CommentRepository(this._dio);
  final Dio _dio;

  /// Mengambil daftar komentar berdasarkan postId dengan batas waktu 10 detik
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
      options: Options(
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}