import 'package:get/get.dart';

import '../controllers/quiz_controller.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../../../data/providers/firebase_provider.dart';

class QuizBinding extends Bindings {
  @override
  void dependencies() {

    /// ================= PROVIDER =================
    Get.lazyPut<FirebaseProvider>(() => FirebaseProvider());

    /// ================= REPOSITORY =================
    Get.lazyPut<QuizRepository>(
      () => QuizRepository(Get.find<FirebaseProvider>()),
    );

    /// ================= CONTROLLER =================
    Get.lazyPut<QuizController>(() => QuizController());
  }
}