import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';

import '../controllers/publication_controller.dart';
import '../../../core/services/download_service.dart';
import '../../../core/services/file_service.dart';

class UploadMaterialView extends GetView<PublicationController> {
  const UploadMaterialView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back()),
        title: Obx(() {
          final isTeacher = controller.userRole.value == "teacher";
          return Text(isTeacher ? "Upload Content" : "Study Materials");
        }),
      ),
      body: Obx(() {
        final isTeacher = controller.userRole.value == "teacher";
        return isTeacher ? _buildUploadUI(cardColor, textColor) : _buildStudentUI(cardColor, textColor);
      }),
    );
  }

  Widget _buildUploadUI(Color cardColor, Color? textColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text("Share notes, files & resources with your class", style: TextStyle(color: textColor?.withValues(alpha: 0.7))),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: controller.pickFile,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent), borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                const Icon(Icons.folder, size: 48, color: Colors.orange),
                const SizedBox(height: 12),
                Text("Tap to upload files", style: TextStyle(color: textColor)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(controller: controller.titleController, decoration: _inputDecoration("Title", "Enter material title", cardColor)),
        const SizedBox(height: 16),
        TextField(controller: controller.descriptionController, maxLines: 3, decoration: _inputDecoration("Description", "Describe material", cardColor)),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          dropdownColor: cardColor,
          value: controller.category.value,
          decoration: _inputDecoration("Category", "", cardColor),
          items: controller.categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (value) => controller.category.value = value!,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          dropdownColor: cardColor,
          value: controller.selectedCourse.value,
          decoration: _inputDecoration("Course", "", cardColor),
          items: controller.courseNames.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (value) => controller.selectedCourse.value = value!,
        ),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: controller.uploadMaterial, child: const Text("Publish Material")),
      ],
    );
  }

  Widget _buildStudentUI(Color cardColor, Color? textColor) {
    final downloadService = DownloadService();
    final box = GetStorage();
    final RxDouble progress = 0.0.obs;
    final RxBool isDownloading = false.obs;
    final RxMap<String, String> localPaths = <String, String>{}.obs;

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('materials').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final materials = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: materials.length,
          itemBuilder: (context, index) {
            final data = materials[index];
            final id = data.id;
            final saved = box.read(id);
            if (saved != null) localPaths[id] = saved;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['title'] ?? "No Title", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(data['description'] ?? "", style: TextStyle(color: textColor?.withValues(alpha: 0.7))),
                  const SizedBox(height: 10),
                  Obx(() => Column(
                        children: [
                          if (!localPaths.containsKey(id))
                            ElevatedButton(
                              onPressed: () async {
                                isDownloading.value = true;
                                final path = await downloadService.downloadFile(
                                  url: data['fileUrl'],
                                  fileName: "${data['title']}.pdf",
                                  onProgress: (p) => progress.value = p,
                                );
                                isDownloading.value = false;
                                if (path != null) {
                                  localPaths[id] = path;
                                  box.write(id, path);
                                  Get.snackbar("Success", "Downloaded for offline use");
                                }
                              },
                              child: const Text("Download"),
                            ),
                          if (isDownloading.value)
                            Column(
                              children: [
                                LinearProgressIndicator(value: progress.value),
                                Text("${(progress.value * 100).toInt()}%", style: TextStyle(color: textColor?.withValues(alpha: 0.7))),
                              ],
                            ),
                          if (localPaths.containsKey(id))
                            ElevatedButton(
                              onPressed: () => FileService.openFile(localPaths[id]!),
                              child: const Text("Open Offline"),
                            ),
                        ],
                      )),
                ],
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, String hint, Color cardColor) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
