import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ExportService {
  /// Writes rows to a CSV file in the app documents directory and returns the path.
  /// [headers] is the first row; [rows] are subsequent rows of string cells.
  Future<String?> exportCsv({
    required String fileName,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final safeName = fileName.endsWith('.csv') ? fileName : '$fileName.csv';
      final path = '${dir.path}/$safeName';
      final buffer = StringBuffer();

      buffer.writeln(headers.map(_escape).join(','));
      for (final row in rows) {
        buffer.writeln(row.map(_escape).join(','));
      }

      final file = File(path);
      await file.writeAsString(buffer.toString());
      return path;
    } catch (e) {
      return null;
    }
  }

  Future<void> openFile(String path) async {
    await OpenFile.open(path);
  }

  String _escape(String cell) {
    final needsQuote = cell.contains(',') || cell.contains('"') || cell.contains('\n');
    final escaped = cell.replaceAll('"', '""');
    return needsQuote ? '"$escaped"' : escaped;
  }
}
