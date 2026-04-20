// placeholder
// lib/modules/assignment/bindings/assignment_binding.dart

import 'package:get/get.dart';

import '../controllers/assignment_controller.dart';

class AssignmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AssignmentController>(
      () => AssignmentController(),
    );
  }
}