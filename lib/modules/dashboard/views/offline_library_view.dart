import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/services/file_service.dart';

class OfflineLibraryView extends StatefulWidget {
  const OfflineLibraryView({super.key});

  @override
  State<OfflineLibraryView> createState() => _OfflineLibraryViewState();
}

class _OfflineLibraryViewState extends State<OfflineLibraryView> {
  final box = GetStorage();
  List<Map<String, String>> files = [];

  @override
  void initState() {
    super.initState();
    loadFiles();
  }

  void loadFiles() {
    final keys = box.getKeys();
    List<Map<String, String>> temp = [];
    for (var key in keys) {
      final value = box.read(key);
      if (value is! String) continue;
      final path = value;
      if (!File(path).existsSync()) continue;
      temp.add({"key": key.toString(), "path": path});
    }
    setState(() => files = temp);
  }

  void deleteFile(String key, String path) {
    try {
      File(path).deleteSync();
      box.remove(key);
      Get.snackbar("Deleted", "File removed successfully");
      loadFiles();
    } catch (e) {
      Get.snackbar("Error", "Failed to delete file");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Offline Library"), backgroundColor: Colors.transparent, elevation: 0),
      body: files.isEmpty
          ? Center(child: Text("No downloaded materials", style: TextStyle(color: textColor?.withValues(alpha: 0.7))))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: files.length,
              itemBuilder: (context, index) {
                final item = files[index];
                final path = item["path"]!;
                final key = item["key"]!;
                final fileName = path.split('/').last;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                      const SizedBox(width: 12),
                      Expanded(child: Text(fileName, style: TextStyle(color: textColor, fontWeight: FontWeight.bold))),
                      IconButton(icon: const Icon(Icons.open_in_new, color: Colors.green), onPressed: () => FileService.openFile(path)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => deleteFile(key, path)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
