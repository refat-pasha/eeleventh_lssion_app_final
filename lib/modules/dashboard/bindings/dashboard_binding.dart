import 'package:get/get.dart';

/// ================= CONTROLLERS =================
import '../controllers/dashboard_controller.dart';
import '../../collaborative/controllers/collaborative_controller.dart';
import '../../progress/controllers/progress_controller.dart';
import '../../quiz/controllers/quiz_controller.dart';
import '../../assignment/controllers/assignment_controller.dart';
import '../../publication/controllers/publication_controller.dart';
import '../../../data/providers/firebase_provider.dart';

/// ================= REPOSITORIES =================
import '../../../data/repositories/quiz_repository.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    /// ================= PROVIDERS (FIRST) =================

    Get.lazyPut<FirebaseProvider>(() => FirebaseProvider());

    /// ================= PROVIDERS (FIRST) =================

    Get.lazyPut<QuizRepository>(
      () => QuizRepository(Get.find<FirebaseProvider>()),
    );

    /// ================= CORE =================
    Get.lazyPut<DashboardController>(() => DashboardController());

    /// ================= TAB CONTROLLERS =================
    Get.lazyPut<CollaborativeController>(() => CollaborativeController());
    Get.lazyPut<ProgressController>(() => ProgressController());
    Get.lazyPut<QuizController>(() => QuizController());
    Get.lazyPut<AssignmentController>(() => AssignmentController());
    Get.lazyPut<PublicationController>(() => PublicationController());
  }
}
