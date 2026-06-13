// lib/utils/error_handler.dart

import '../services/api/api_client.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is BadRequestException) {
      return error.message.isNotEmpty
          ? error.message
          : 'Data tidak valid. Periksa kembali input Anda.';
    }
    // else if (error is UnauthorizedException) {
    //   return 'Email atau kata sandi salah.';
    // }
    else if (error is ForbiddenException) {
      return 'Anda tidak memiliki akses ke resource ini.';
    } else if (error is NotFoundException) {
      return 'Data tidak ditemukan.';
    } else if (error is ServerException) {
      return 'Server error. Silakan coba lagi nanti.';
    } else if (error is ApiException) {
      return error.message.isNotEmpty ? error.message : 'Terjadi kesalahan.';
    }
    final msg = error.toString();
    if (msg.contains('SocketException') || msg.contains('Network')) {
      return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
    }
    return msg.isNotEmpty ? msg : 'Terjadi kesalahan yang tidak diketahui.';
  }
}
