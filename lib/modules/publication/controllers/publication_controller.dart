import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/providers/firebase_provider.dart';
import '../../../core/services/google_drive_service.dart';
import 'dart:io';
import 'dart:typed_data';

class PublicationController extends GetxController {

  /// Firebase Provider
  final FirebaseProvider firebaseProvider = Get.find();

  /// Google Drive Service
  final GoogleDriveService _driveService = GoogleDriveService();

  /// ================= USER ROLE =================
  final RxString userRole = "student".obs;

  /// ================= TEXT CONTROLLERS =================
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final tagsController = TextEditingController();

  /// ================= FILE =================
  PlatformFile? selectedFile;

  /// ================= UI STATE =================
  var fileName = "".obs;
  var isUploading = false.obs;

  /// ================= DROPDOWN =================
  var category = "Lecture Notes".obs;
  var selectedCourse = "CSE 221".obs;
  var visibility = "My Courses".obs;

  final categories = [
    "Lecture Notes",
    "Slides",
    "Assignment",
    "Exam Prep",
  ];

  final courseNames = [
    "CSE 221",
    "MATH 301",
    "CSE 341",
  ];

  final visibilityOptions = [
    "My Courses",
    "Public",
    "Private"
  ];

  /// ================= INIT =================
  @override
  void onInit() {
    super.onInit();
    fetchUserRole();
  }

  /// ================= FETCH ROLE =================
  Future<void> fetchUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final userDoc = await firebaseProvider.users().doc(user.uid).get();

      final data = userDoc.data() as Map<String, dynamic>?;

      if (data != null && data["role"] != null) {
        userRole.value = data["role"];
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load user role");
    }
  }

  /// ================= PICK FILE =================
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
    );

    if (result != null) {
      selectedFile = result.files.first;
      fileName.value = selectedFile!.name;
    }
  }

  /// ================= UPLOAD MATERIAL =================
  Future<void> uploadMaterial() async {

    /// VALIDATION
    if (selectedFile == null) {
      Get.snackbar("Error", "Please select a file");
      return;
    }

    if (titleController.text.isEmpty) {
      Get.snackbar("Error", "Title is required");
      return;
    }

    /// ROLE CHECK
    if (userRole.value != "teacher") {
      Get.snackbar("Access Denied", "Only teachers can upload materials");
      return;
    }

    try {
      isUploading.value = true;

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        Get.snackbar("Error", "User not logged in");
        return;
      }

      final userId = user.uid;

      /// ================= GOOGLE DRIVE UPLOAD =================
      final fileBytes = selectedFile!.bytes;

      if (fileBytes == null) {
        Get.snackbar("Error", "File data is missing");
        return;
      }

      /// Convert bytes → temp file
      final tempFile = await _createTempFile(fileBytes, selectedFile!.name);

      final fileId = await _driveService.uploadFile(tempFile);

      if (fileId == null) {
        Get.snackbar("Upload Failed", "Google Drive upload failed");
        return;
      }

      final downloadUrl = _driveService.getDownloadUrl(fileId);

      /// ================= FIRESTORE =================
      await firebaseProvider.materials().add({
        "title": titleController.text.trim(),
        "description": descriptionController.text.trim(),
        "category": category.value,
        "courseId": selectedCourse.value,
        "visibility": visibility.value,
        "tags": tagsController.text
            .split(",")
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        "fileName": selectedFile!.name,
        "fileUrl": downloadUrl,
        "fileId": fileId, // 🔥 NEW (important)
        "uploadedBy": userId,
        "createdAt": FieldValue.serverTimestamp(),
      });

      clearForm();

      Get.snackbar(
        "Success",
        "Material uploaded successfully",
        snackPosition: SnackPosition.BOTTOM,
      );

    } catch (e) {
      Get.snackbar(
        "Upload Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      print("Upload Error: $e");

    } finally {
      isUploading.value = false;
    }
  }

  /// ================= TEMP FILE CREATION =================
  Future<File> _createTempFile(Uint8List bytes, String name) async {
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/$name');
    return await file.writeAsBytes(bytes);
  }

  /// ================= CLEAR =================
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    tagsController.clear();

    selectedFile = null;
    fileName.value = "";
  }

  /// ================= DISPOSE =================
  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    tagsController.dispose();
    super.onClose();
  }
}