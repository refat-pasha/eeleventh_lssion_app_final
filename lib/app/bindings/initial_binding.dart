import 'package:get/get.dart';

import '../../data/providers/firebase_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/course_repository.dart';
import '../../data/repositories/assignment_repository.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../data/repositories/material_repository.dart';
import '../../core/services/sync_service.dart';

/// 🔥 ADD THESE IMPORTS
import '../../modules/publication/controllers/publication_controller.dart';
import '../../modules/progress/controllers/progress_controller.dart';
import '../../modules/dashboard/controllers/dashboard_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {

    /// ================= PROVIDERS =================
    Get.put<FirebaseProvider>(FirebaseProvider(), permanent: true);

    /// ================= SERVICES =================
    Get.put<SyncService>(SyncService(), permanent: true);

    /// ================= REPOSITORIES =================
    Get.put<AuthRepository>(
      AuthRepository(Get.find<FirebaseProvider>()),
      permanent: true,
    );

    Get.lazyPut<CourseRepository>(
      () => CourseRepository(Get.find<FirebaseProvider>()),
    );

    Get.lazyPut<AssignmentRepository>(
      () => AssignmentRepository(Get.find<FirebaseProvider>()),
    );

    Get.lazyPut<QuizRepository>(
      () => QuizRepository(Get.find<FirebaseProvider>()),
    );

    Get.lazyPut<MaterialRepository>(
      () => MaterialRepository(Get.find<FirebaseProvider>()),
    );

    /// ================= CONTROLLERS =================
    /// Lazy so they instantiate only when a route requests them —
    /// avoids running onInit (and any Get.snackbar inside it) before
    /// the GetMaterialApp overlay is attached.
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<ProgressController>(() => ProgressController(), fenix: true);
    Get.lazyPut<PublicationController>(() => PublicationController(), fenix: true);
  }
}