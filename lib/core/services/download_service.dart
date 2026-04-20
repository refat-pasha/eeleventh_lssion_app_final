import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  final Dio _dio = Dio();

  /// ================= DOWNLOAD FILE =================
  /// Returns local file path
  Future<String?> downloadFile({
    required String url,
    required String fileName,
    Function(double progress)? onProgress, // optional progress callback
  }) async {
    try {
      /// Get device storage directory
      final dir = await getApplicationDocumentsDirectory();

      /// Create full file path
      final filePath = "${dir.path}/$fileName";

      /// Download file
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            double progress = received / total;
            onProgress(progress); // send progress (0.0 → 1.0)
          }
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      /// Check if file exists
      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      } else {
        return null;
      }

    } catch (e) {
      print("Download error: $e");
      return null;
    }
  }

  /// ================= CHECK FILE EXISTS =================
  Future<bool> fileExists(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = "${dir.path}/$fileName";

    return File(filePath).exists();
  }

  /// ================= GET FILE PATH =================
  Future<String> getFilePath(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    return "${dir.path}/$fileName";
  }

  /// ================= DELETE FILE =================
  Future<void> deleteFile(String fileName) async {
    try {
      final path = await getFilePath(fileName);
      final file = File(path);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print("Delete error: $e");
    }
  }
}