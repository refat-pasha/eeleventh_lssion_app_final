import 'package:get/get.dart';
import '../controllers/academic_profile_controller.dart';

class AcademicProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AcademicProfileController>(
      () => AcademicProfileController(),
    );
  }
}