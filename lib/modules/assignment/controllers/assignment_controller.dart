// lib/modules/assignment/controllers/assignment_controller.dart

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/models/assignment_model.dart';
import '../../../data/models/assignment_submission_model.dart';
import '../../../data/providers/firebase_provider.dart';
import '../../../data/repositories/assignment_repository.dart';

class AssignmentController extends GetxController {
  late AssignmentRepository _assignmentRepository;

  /// ================= STATE =================
  final RxList<AssignmentModel> assignments = <AssignmentModel>[].obs;

  /// 🔥 NEW
  final RxList<AssignmentSubmissionModel> submissions =
      <AssignmentSubmissionModel>[].obs;

  final RxBool isLoading = false.obs;

  /// ================= USER ROLE =================
  final RxString userRole = "student".obs;
  bool get isTeacher => userRole.value == "teacher" || userRole.value == "admin";

  late final FirebaseProvider _firebaseProvider;

  /// ================= INIT =================
  @override
  void onInit() {
    super.onInit();

    _firebaseProvider = FirebaseProvider();
    _assignmentRepository = AssignmentRepository(_firebaseProvider);

    fetchUserRole();
    fetchAssignments();
    listenToAssignments();
  }

  /// ================= FETCH ROLE =================
  Future<void> fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await _firebaseProvider.users().doc(user.uid).get();
    final data = doc.data() as Map<String, dynamic>?;
    if (data != null && data["role"] != null) {
      userRole.value = data["role"];
    }
  }

  /// ================= FETCH ASSIGNMENTS =================
  Future<void> fetchAssignments() async {
    try {
      isLoading.value = true;

      final data = await _assignmentRepository.getAssignments();
      assignments.assignAll(data);

    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= REAL-TIME ASSIGNMENTS =================
  void listenToAssignments() {
    FirebaseFirestore.instance
        .collection('assignments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final data = snapshot.docs.map((doc) {
        return AssignmentModel.fromMap(doc.data(), doc.id);
      }).toList();

      assignments.assignAll(data);
    });
  }

  /// ================= CREATE =================
  Future<void> createAssignment(AssignmentModel assignment) async {
    try {
      await _assignmentRepository.createAssignment(assignment);
      Get.snackbar("Success", "Assignment created");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// ================= DELETE =================
  Future<void> deleteAssignment(String id) async {
    try {
      await _assignmentRepository.deleteAssignment(id);
      Get.snackbar("Deleted", "Assignment removed");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  // ============================================================
  // 🔥 🔥 🔥 STUDENT SIDE 🔥 🔥 🔥
  // ============================================================

  /// ================= SUBMIT ASSIGNMENT =================
  Future<void> submitAssignment({
    required String assignmentId,
    required String courseId,
    required String answer,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        Get.snackbar("Error", "User not logged in");
        return;
      }

      if (answer.trim().isEmpty) {
        Get.snackbar("Error", "Answer cannot be empty");
        return;
      }

      await FirebaseFirestore.instance
          .collection('assignment_submissions')
          .add({
        "assignmentId": assignmentId,
        "userId": user.uid,
        "courseId": courseId,
        "answer": answer.trim(),
        "fileUrl": "",
        "marks": null,
        "feedback": "",
        "status": "submitted",
        "submittedAt": FieldValue.serverTimestamp(),
        "gradedAt": null,
      });

      Get.snackbar("Success", "Assignment submitted");

    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// ================= GET STUDENT SUBMISSIONS =================
  Future<void> fetchMySubmissions() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('assignment_submissions')
          .where("userId", isEqualTo: user.uid)
          .orderBy("submittedAt", descending: true)
          .get();

      final data = snapshot.docs.map((doc) {
        return AssignmentSubmissionModel.fromMap(
          doc.data(),
          doc.id,
        );
      }).toList();

      submissions.assignAll(data);

    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  // ============================================================
  // 🔥 🔥 🔥 TEACHER SIDE 🔥 🔥 🔥
  // ============================================================

  /// ================= GET SUBMISSIONS FOR ASSIGNMENT =================
  Future<void> fetchSubmissionsByAssignment(String assignmentId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('assignment_submissions')
          .where("assignmentId", isEqualTo: assignmentId)
          .orderBy("submittedAt", descending: true)
          .get();

      final data = snapshot.docs.map((doc) {
        return AssignmentSubmissionModel.fromMap(
          doc.data(),
          doc.id,
        );
      }).toList();

      submissions.assignAll(data);

    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// ================= GRADE SUBMISSION =================
  Future<void> gradeSubmission({
    required String submissionId,
    required int marks,
    required String feedback,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('assignment_submissions')
          .doc(submissionId)
          .update({
        "marks": marks,
        "feedback": feedback,
        "status": "graded",
        "gradedAt": FieldValue.serverTimestamp(),
      });

      Get.snackbar("Success", "Assignment graded");

    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}