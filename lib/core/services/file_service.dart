import 'dart:io';
import 'package:open_file/open_file.dart';

class FileService {

  /// ================= OPEN FILE =================
  static Future<void> openFile(String path) async {
    try {
      final file = File(path);

      if (!await file.exists()) {
        print("File not found");
        return;
      }

      final result = await OpenFile.open(path);

      if (result.type != ResultType.done) {
        print("Error opening file: ${result.message}");
      }

    } catch (e) {
      print("Open file error: $e");
    }
  }

  /// ================= CHECK FILE EXISTS =================
  static Future<bool> fileExists(String path) async {
    final file = File(path);
    return await file.exists();
  }

  /// ================= DELETE FILE =================
  static Future<void> deleteFile(String path) async {
    try {
      final file = File(path);

      if (await file.exists()) {
        await file.delete();
      }

    } catch (e) {
      print("Delete file error: $e");
    }
  }

  /// ================= GET FILE SIZE =================
  static Future<int> getFileSize(String path) async {
    try {
      final file = File(path);

      if (await file.exists()) {
        return await file.length();
      }

      return 0;
    } catch (e) {
      print("File size error: $e");
      return 0;
    }
  }
}