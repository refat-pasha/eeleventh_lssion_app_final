import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/providers/firebase_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../profile/controllers/profile_controller.dart';

class AcademicProfileController extends GetxController {
  final FirebaseProvider firebaseProvider = Get.find();
  final AuthRepository authRepository = Get.find();

  final universityController = TextEditingController();
  final departmentController = TextEditingController();
  final semesterController = TextEditingController();
  final subjectsController = TextEditingController();

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAcademicInfo();
  }

  /// ================= LOAD EXISTING DATA =================
  Future<void> loadAcademicInfo() async {
    try {
      isLoading.value = true;

      final firebaseUser = authRepository.currentUser;
      if (firebaseUser == null) return;

      final doc = await firebaseProvider
          .users()
          .doc(firebaseUser.uid)
          .get();

      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;

      universityController.text = data["university"] ?? "";
      departmentController.text = data["department"] ?? "";
      semesterController.text = data["semester"] ?? "";

      if (data["subjects"] != null) {
        subjectsController.text =
            (data["subjects"] as List).join(", ");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= SAVE DATA =================
  Future<void> saveAcademicInfo() async {
    try {
      isLoading.value = true;

      final firebaseUser = authRepository.currentUser;
      if (firebaseUser == null) return;

      final subjects = subjectsController.text
          .split(",")
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      await firebaseProvider
          .users()
          .doc(firebaseUser.uid)
          .update({
        "university": universityController.text.trim(),
        "department": departmentController.text.trim(),
        "semester": semesterController.text.trim(),
        "subjects": subjects,
      });

      /// 🔥 VERY IMPORTANT FIX
      /// Refresh Profile Screen instantly
      if (Get.isRegistered<ProfileController>()) {
        await Get.find<ProfileController>().loadProfile();
      }

      Get.snackbar("Success", "Academic profile updated");

      /// Go back to profile screen
      Get.back();

    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    universityController.dispose();
    departmentController.dispose();
    semesterController.dispose();
    subjectsController.dispose();
    super.onClose();
  }
}