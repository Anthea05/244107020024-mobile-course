import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/comment.dart';
import 'providers.dart';
import 'repositories/comment_repository.dart';

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepository(ref.watch(dioProvider));
});

final commentListProvider = FutureProvider.autoDispose
    .family<List<Comment>, int>((ref, postId) async {
      final repo = ref.watch(commentRepositoryProvider);
      return repo.fetchComments(postId);
    });

String friendlyCommentErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Waktu koneksi habis. Silakan coba kembali.';
      case DioExceptionType.connectionError:
        return 'Tidak ada sambungan internet.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 404) return 'Komentar tidak ditemukan (404).';
        if (code == 500) return 'Server sedang mengalami gangguan (500).';
        return 'Terjadi galat server ($code).';
      default:
        return 'Gagal memuat komentar. Periksa jaringan Anda.';
    }
  }
  return 'Terjadi error tidak terduga: $error';
}
