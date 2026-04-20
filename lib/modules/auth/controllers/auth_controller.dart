import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  late final AuthRepository _authRepository;

  final RxBool isLoading = false.obs;
  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxString selectedRole = ''.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    _authRepository = Get.find<AuthRepository>();
    super.onInit();
  }

  // ================= LOGIN =================
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final result = await _authRepository.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (result != null) {
        final profile =
            await _authRepository.getUserProfile(result.user!.uid);

        if (profile == null || profile.role.isEmpty) {
          Get.offAllNamed(Routes.setupProfile);
        } else {
          user.value = profile;
          Get.offAllNamed(Routes.dashboard);
        }
      }
    } catch (e) {
      Get.snackbar("Login Failed", e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ================= REGISTER =================
  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final result = await _authRepository.register(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        name: nameController.text.trim(),
      );

      if (result != null) {
        Get.offAllNamed(Routes.setupProfile);
      }
    } catch (e) {
      Get.snackbar("Registration Failed", e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ================= ROLE SELECT =================
  void selectRole(String role) {
    selectedRole.value = role;
  }

  // ================= SAVE PROFILE =================
  Future<void> saveProfile() async {
    if (selectedRole.value.isEmpty) {
      Get.snackbar(
        "Role Required",
        "Please select Student or Teacher",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final firebaseUser = _authRepository.currentUser;

      if (firebaseUser == null) {
        Get.offAllNamed(Routes.login);
        return;
      }

      final existing =
          await _authRepository.getUserProfile(firebaseUser.uid);

      final userModel = UserModel(
        id: firebaseUser.uid,

        name: nameController.text.trim().isEmpty
            ? (firebaseUser.displayName ??
                existing?.name ??
                "User")
            : nameController.text.trim(),

        email: firebaseUser.email ?? "",
        role: selectedRole.value,

        university: existing?.university,
        department: existing?.department,
        semester: existing?.semester,

        subjects: existing?.subjects ?? [],
        enrolledCourses: existing?.enrolledCourses ?? [],

        xp: existing?.xp ?? 0,
        level: existing?.level ?? 1, // ✅ FIXED
        streak: existing?.streak ?? 0,
        achievements: existing?.achievements ?? [],

        /// 🔥 FIX: REMOVE totalCourse dependency
        /// Instead calculate dynamically later

        createdAt: existing?.createdAt ?? DateTime.now(),
      );

      await _authRepository.saveUserProfile(userModel);
      user.value = userModel;

      Get.offAllNamed(Routes.dashboard);
    } catch (e) {
      Get.snackbar("Profile Save Failed", e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ================= LOAD USER PROFILE =================
  Future<void> loadUserProfile() async {
    final firebaseUser = _authRepository.currentUser;

    if (firebaseUser != null) {
      final profile =
          await _authRepository.getUserProfile(firebaseUser.uid);
      user.value = profile;
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await _authRepository.logout();

    user.value = null;
    selectedRole.value = '';

    emailController.clear();
    passwordController.clear();
    nameController.clear();

    Get.offAllNamed(Routes.login);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.onClose();
  }
}