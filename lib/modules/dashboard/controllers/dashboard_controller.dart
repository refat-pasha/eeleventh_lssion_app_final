import 'package:get/get.dart';

import '../../../data/models/user_model.dart';
import '../../../data/models/course_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/providers/firebase_provider.dart';

class DashboardController extends GetxController {
  /// ================= REPOSITORIES =================
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final CourseRepository _courseRepository = Get.find<CourseRepository>();
  final FirebaseProvider firebaseProvider = Get.find<FirebaseProvider>();

  /// ================= STATE =================
  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxList<CourseModel> courses = <CourseModel>[].obs;

  final RxBool isLoading = true.obs;

  bool get isTeacher =>
      user.value?.role == "teacher" || user.value?.role == "admin";

  /// 🔥 SMART SYSTEM
  final RxList<dynamic> recommendedMaterials = [].obs;
  final RxList<dynamic> suggestedQuizzes = [].obs;
  final Rxn<dynamic> continueMaterial = Rxn();

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
    generateRecommendations(); // 🔥 smart system
  }

  /// ================= LOAD DASHBOARD =================
  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;

      final firebaseUser = _authRepository.currentUser;

      if (firebaseUser == null) {
        Get.offAllNamed("/login");
        return;
      }

      /// USER PROFILE
      final profile =
          await _authRepository.getUserProfile(firebaseUser.uid);

      user.value = profile;

      /// COURSE LIST — branches on role
      if (profile?.role == "teacher" || profile?.role == "admin") {
        /// Teachers see courses they own
        final taught =
            await _courseRepository.getCoursesByTeacher(firebaseUser.uid);
        courses.assignAll(taught);
        print("Teacher-owned courses count: ${taught.length}");
      } else {
        /// Students see enrolled courses (fall back to all if none enrolled)
        final allCourses = await _courseRepository.getCourses();
        final enrolledIds = profile?.enrolledCourses ?? [];

        final filteredCourses = allCourses.where((course) {
          return enrolledIds.contains(course.id);
        }).toList();

        if (filteredCourses.isEmpty) {
          courses.assignAll(allCourses);
        } else {
          courses.assignAll(filteredCourses);
        }

        print("User enrolled courses: $enrolledIds");
        print("Filtered courses count: ${courses.length}");
      }

    } catch (e) {
      print("Dashboard load error: $e");
      if (Get.overlayContext != null) {
        Get.snackbar("Dashboard Error", e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= SMART RECOMMENDATIONS =================
  Future<void> generateRecommendations() async {
    try {
      final firebaseUser = _authRepository.currentUser;
      if (firebaseUser == null) return;

      final profile =
          await _authRepository.getUserProfile(firebaseUser.uid);

      /// ================= CONTINUE LEARNING =================
      /// Sorted client-side to avoid the composite index requirement
      /// (userId asc + viewedAt desc).
      final recent = await firebaseProvider
          .materialViews()
          .where("userId", isEqualTo: firebaseUser.uid)
          .get();

      if (recent.docs.isNotEmpty) {
        final docs = recent.docs.toList()
          ..sort((a, b) {
            final av = a['viewedAt'];
            final bv = b['viewedAt'];
            if (av == null && bv == null) return 0;
            if (av == null) return 1;
            if (bv == null) return -1;
            return (bv as Comparable).compareTo(av as Comparable);
          });

        final materialId = docs.first['materialId'];

        final mat = await firebaseProvider
            .materials()
            .doc(materialId)
            .get();

        continueMaterial.value = mat.data();
      }

      /// ================= RECOMMENDED MATERIALS =================
      final enrolledCourses = profile?.enrolledCourses ?? [];

      final materials = await firebaseProvider
          .materials()
          .where("courseId",
              whereIn: enrolledCourses.isEmpty ? ["none"] : enrolledCourses)
          .limit(5)
          .get();

      recommendedMaterials.assignAll(materials.docs);

      /// ================= SUGGESTED QUIZZES =================
      final quizzes = await firebaseProvider
          .quizzes()
          .limit(5)
          .get();

      suggestedQuizzes.assignAll(quizzes.docs);

      print("Recommendations loaded");

    } catch (e) {
      print("Recommendation error: $e");
    }
  }

  /// ================= REFRESH =================
  Future<void> refreshDashboard() async {
    await loadDashboard();
    await generateRecommendations();
  }

  /// ================= CREATE COURSE (TEACHER) =================
  Future<void> createCourse({
    required String title,
    required String code,
    required String description,
  }) async {
    final firebaseUser = _authRepository.currentUser;
    if (firebaseUser == null) {
      Get.snackbar("Error", "You must be logged in");
      return;
    }

    if (!isTeacher) {
      Get.snackbar("Access Denied", "Only teachers can create courses");
      return;
    }

    final trimmedTitle = title.trim();
    final trimmedCode = code.trim();
    if (trimmedTitle.isEmpty || trimmedCode.isEmpty) {
      Get.snackbar("Error", "Title and Code are required");
      return;
    }

    try {
      await _courseRepository.createCourse(
        CourseModel(
          id: '',
          title: trimmedTitle,
          code: trimmedCode,
          description: description.trim(),
          teacherId: firebaseUser.uid,
          createdAt: DateTime.now(),
        ),
      );

      await loadDashboard();
      Get.snackbar("Success", "Course created");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}