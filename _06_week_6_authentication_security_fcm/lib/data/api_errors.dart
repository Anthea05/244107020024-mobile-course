import 'package:dio/dio.dart';

String getFriendlyErrorMessage(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Koneksi lambat. Silakan periksa jaringan Anda.';
    case DioExceptionType.badResponse:
      if (error.response?.statusCode == 401) {
        return 'Sesi habis. Silakan login kembali.';
      }
      return 'Terjadi kesalahan pada server (Error ${error.response?.statusCode}).';
    case DioExceptionType.connectionError:
      return 'Tidak ada koneksi internet.';
    default:
      return 'Terjadi kesalahan yang tidak diketahui.';
  }
}
