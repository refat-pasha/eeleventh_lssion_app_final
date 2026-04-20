import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/providers/firebase_provider.dart';
import '../../../data/repositories/auth_repository.dart';

class AccountSettingsController extends GetxController {
  final FirebaseProvider firebaseProvider = Get.find<FirebaseProvider>();
  final AuthRepository authRepository = Get.find<AuthRepository>();

  final nameController = TextEditingController();
  final ageController = TextEditingController();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAccountSettings();
  }

  Future<void> loadAccountSettings() async {
    try {
      isLoading.value = true;

      final user = authRepository.currentUser;
      if (user == null) return;

      final doc = await firebaseProvider.users().doc(user.uid).get();

      if (!doc.exists || doc.data() == null) return;

      final data = doc.data() as Map<String, dynamic>;

      nameController.text = data["name"] ?? "";
      ageController.text = data["age"]?.toString() ?? "";
    } catch (e) {
      Get.snackbar("Load Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveAccountSettings() async {
    try {
      isLoading.value = true;

      final user = authRepository.currentUser;
      if (user == null) return;

      await firebaseProvider.users().doc(user.uid).update({
        "name": nameController.text.trim(),
        "age": int.tryParse(ageController.text.trim()),
      });

      Get.snackbar("Success", "Profile updated");
    } catch (e) {
      Get.snackbar("Save Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    ageController.dispose();
    super.onClose();
  }
}