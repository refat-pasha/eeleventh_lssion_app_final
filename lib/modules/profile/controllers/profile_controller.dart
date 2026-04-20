import 'dart:async'; // 🔥 IMPORTANT

import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/providers/firebase_provider.dart';

class ProfileController extends GetxController {
  final AuthRepository authRepository = Get.find();
  final FirebaseProvider firebaseProvider = Get.find();

  final user = Rxn<UserModel>();
  final isLoading = true.obs;

  /// 🔥 Real-time listener
  StreamSubscription? userSubscription;

  @override
  void onInit() {
    super.onInit();

    /// Choose ONE:
    loadProfile();
    // listenToUser(); // 🔥 optional
  }

  /// ================= LOAD PROFILE =================
  Future<void> loadProfile() async {
    try {
      isLoading.value = true;

      final firebaseUser = authRepository.currentUser;
      if (firebaseUser == null) return;

      final profile =
          await authRepository.getUserProfile(firebaseUser.uid);

      user.value = profile;
    } catch (e) {
      Get.snackbar("Profile Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= REAL-TIME SYNC =================
  void listenToUser() {
    final firebaseUser = authRepository.currentUser;
    if (firebaseUser == null) return;

    userSubscription = firebaseProvider
        .users()
        .doc(firebaseUser.uid)
        .snapshots()
        .listen((doc) {
      final data = doc.data();

      if (doc.exists && data != null) {
        user.value = UserModel.fromMap(
          data as Map<String, dynamic>,
          doc.id,
        );
      }
    });
  }

  /// ================= REFRESH =================
  Future<void> refreshProfile() async {
    await loadProfile();
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    await authRepository.logout();

    user.value = null;

    userSubscription?.cancel();

    Get.offAllNamed("/login");
  }

  @override
  void onClose() {
    userSubscription?.cancel();
    super.onClose();
  }
}