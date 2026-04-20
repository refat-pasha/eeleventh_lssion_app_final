import 'package:get/get.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../app/routes/app_routes.dart';

class SplashController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  bool _alreadyChecked = false;

  Future<void> checkUserFlow() async {
    if (_alreadyChecked) return;
    _alreadyChecked = true;

    print("🔵 SplashController started...");

    await Future.delayed(const Duration(seconds: 2));

    try {
      final firebaseUser = _authRepository.currentUser;

      print("🟡 Firebase user: ${firebaseUser?.uid}");

      if (firebaseUser == null) {
        print("🔴 No user found -> going to login");
        Get.offAllNamed(Routes.login);
        return;
      }

      print("🟣 Fetching Firestore profile...");

      final profile = await _authRepository
          .getUserProfile(firebaseUser.uid)
          .timeout(const Duration(seconds: 5));

      print("🟢 Profile loaded: ${profile?.role}");

      if (profile == null || profile.role.isEmpty) {
        print("🟠 No role/profile -> going to setup profile");
        Get.offAllNamed(Routes.setupProfile);
      } else {
        print("✅ Profile complete -> going to dashboard");
        Get.offAllNamed(Routes.dashboard);
      }
    } catch (e) {
      print("❌ Splash error: $e");
      Get.offAllNamed(Routes.login);
    }
  }
}