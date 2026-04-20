import 'package:get/get.dart';

import '../controllers/progress_controller.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/providers/firebase_provider.dart';

class ProgressBinding extends Bindings {
  @override
  void dependencies() {

    /// 🔹 Firebase Provider (FIRST)
    if (!Get.isRegistered<FirebaseProvider>()) {
      Get.lazyPut<FirebaseProvider>(() => FirebaseProvider());
    }

    /// 🔹 Auth Repository (PASS provider)
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(
        () => AuthRepository(Get.find<FirebaseProvider>()),
      );
    }

    /// 🔹 Course Repository (PASS provider)
    if (!Get.isRegistered<CourseRepository>()) {
      Get.lazyPut<CourseRepository>(
        () => CourseRepository(Get.find<FirebaseProvider>()),
      );
    }

    /// 🔹 Progress Controller
    Get.lazyPut<ProgressController>(() => ProgressController());
  }
}